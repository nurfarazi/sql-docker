# Script to copy SSH public key to the container (Windows equivalent of ssh-copy-id)

$containerName = "sqlwin-ssh"
$sshPort = 2222
$sshUser = "root"
$sshPassword = "SshPassw0rd!"
$publicKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"

Write-Host "=== Copying SSH Key to Container ===" -ForegroundColor Cyan

# Check if public key exists
if (-not (Test-Path $publicKeyPath)) {
    Write-Host "Error: Public key not found at $publicKeyPath" -ForegroundColor Red
    Write-Host "Run: ssh-keygen -t rsa -b 4096" -ForegroundColor Yellow
    exit 1
}

Write-Host "Reading public key from: $publicKeyPath" -ForegroundColor Gray
$publicKey = Get-Content $publicKeyPath -Raw

# Check if container is running
$containerStatus = docker inspect --format='{{.State.Running}}' $containerName 2>$null
if ($containerStatus -ne 'true') {
    Write-Host "Error: Container '$containerName' is not running" -ForegroundColor Red
    Write-Host "Run: .\00-setup-ssh-container.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Container '$containerName' is running" -ForegroundColor Green

# Copy the public key to container
Write-Host "`nCopying SSH public key to container..." -ForegroundColor Yellow

# Create .ssh directory and authorized_keys file in container
docker exec $containerName bash -c "mkdir -p /root/.ssh && chmod 700 /root/.ssh"
docker exec $containerName bash -c "echo '$publicKey' >> /root/.ssh/authorized_keys"
docker exec $containerName bash -c "chmod 600 /root/.ssh/authorized_keys"
docker exec $containerName bash -c "chown -R root:root /root/.ssh"

Write-Host "SSH key copied successfully!" -ForegroundColor Green

# Test SSH connection
Write-Host "`nTesting SSH connection..." -ForegroundColor Yellow
Write-Host "Attempting to connect to root@localhost:$sshPort" -ForegroundColor Gray

$testResult = ssh -o "StrictHostKeyChecking=no" -p $sshPort root@localhost "echo 'SSH connection successful!'" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ SSH connection successful!" -ForegroundColor Green
    Write-Host "Output: $testResult" -ForegroundColor White
} else {
    Write-Host "SSH connection test failed" -ForegroundColor Red
    Write-Host "Output: $testResult" -ForegroundColor Gray
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "You can now use PSSession with:" -ForegroundColor White
Write-Host '  $session = New-PSSession -HostName localhost -Port 2222 -UserName root' -ForegroundColor Gray
Write-Host "`nOr run the example script:" -ForegroundColor White
Write-Host "  .\06-pssession-examples.ps1" -ForegroundColor Gray
