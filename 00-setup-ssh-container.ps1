# Script to set up SQL Server container with SSH for TRUE PSSession support
# This demonstrates how to configure a container for PowerShell remoting

Write-Host "=== Setting up SQL Server Container with SSH for PSSession ===" -ForegroundColor Cyan
Write-Host "This creates a new container with SSH enabled for true PowerShell remoting`n" -ForegroundColor Gray

$containerName = "sqlwin-ssh"
$saPassword = "YourStrong!Passw0rd"
$sshPassword = "SshPassw0rd!"

Write-Host "Step 1: Creating Dockerfile with SSH support..." -ForegroundColor Yellow

$dockerfileContent = @'
FROM mcr.microsoft.com/mssql/server:2019-latest

# Install SSH and PowerShell
USER root
RUN apt-get update && \
    apt-get install -y openssh-server wget apt-transport-https software-properties-common && \
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    mkdir /var/run/sshd && \
    echo 'root:SshPassw0rd!' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo 'Subsystem powershell /usr/bin/pwsh -sshs -NoLogo' >> /etc/ssh/sshd_config && \
    pwsh -c "Install-Module -Name PSWSMan -Force -Scope AllUsers" || true

# Expose SQL and SSH ports
EXPOSE 1433 22

# Set SQL Server environment
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong!Passw0rd

# Start both SQL Server and SSH
CMD service ssh start && /opt/mssql/bin/sqlservr
'@

$dockerfileContent | Out-File -FilePath ".\Dockerfile.ssh" -Encoding UTF8 -Force
Write-Host "Dockerfile.ssh created!" -ForegroundColor Green

Write-Host "`nStep 2: Building custom SQL Server image with SSH..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

$buildResult = docker build -f Dockerfile.ssh -t sqlserver-ssh:latest . 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Image built successfully!" -ForegroundColor Green
} else {
    Write-Host "Build failed. Output:" -ForegroundColor Red
    $buildResult | ForEach-Object { Write-Host $_ }
    exit 1
}

Write-Host "`nStep 3: Running container with SSH enabled..." -ForegroundColor Yellow

# Remove old container if exists
docker rm -f $containerName 2>$null

$runResult = docker run -d `
    --name $containerName `
    -p 1434:1433 `
    -p 2222:22 `
    sqlserver-ssh:latest

if ($LASTEXITCODE -eq 0) {
    Write-Host "Container started successfully!" -ForegroundColor Green
    Write-Host "Container ID: $runResult" -ForegroundColor Gray
} else {
    Write-Host "Failed to start container" -ForegroundColor Red
    exit 1
}

# Wait for services to start
Write-Host "`nWaiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "`n=== Container Configuration ===" -ForegroundColor Cyan
Write-Host "Container Name: $containerName" -ForegroundColor White
Write-Host "SQL Server Port: 1434 (mapped from 1433)" -ForegroundColor White
Write-Host "SSH Port: 2222 (mapped from 22)" -ForegroundColor White
Write-Host "SA Password: $saPassword" -ForegroundColor White
Write-Host "SSH User: root" -ForegroundColor White
Write-Host "SSH Password: $sshPassword" -ForegroundColor White

Write-Host "`n=== How to use PSSession ===" -ForegroundColor Yellow
Write-Host @"
# Test SSH connection first:
ssh root@localhost -p 2222
(password: $sshPassword)

# Create PSSession (requires SSH key setup):
`$session = New-PSSession -HostName localhost -Port 2222 -UserName root

# Or use Invoke-Command directly:
Invoke-Command -HostName localhost -Port 2222 -UserName root -ScriptBlock {
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P '$saPassword' -Q "SELECT @@VERSION"
}
"@ -ForegroundColor Gray

Write-Host "`nNote: For passwordless PSSession, set up SSH keys:" -ForegroundColor Yellow
Write-Host "  ssh-keygen -t rsa -b 4096" -ForegroundColor Gray
Write-Host "  ssh-copy-id -p 2222 root@localhost" -ForegroundColor Gray
