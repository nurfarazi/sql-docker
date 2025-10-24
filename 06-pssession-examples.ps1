# Example script demonstrating TRUE PSSession with SSH-enabled container
# Run 00-setup-ssh-container.ps1 first to create the SSH-enabled container

$containerHost = "localhost"
$sshPort = 2222
$sshUser = "root"
$saPassword = "YourStrong!Passw0rd"
$database = "TestDB"

Write-Host "=== Demonstrating TRUE PSSession with SQL Server Container ===" -ForegroundColor Cyan
Write-Host "This uses PowerShell Remoting over SSH`n" -ForegroundColor Gray

try {
    Write-Host "Creating PSSession to container via SSH..." -ForegroundColor Yellow
    Write-Host "Host: $containerHost | Port: $sshPort | User: $sshUser" -ForegroundColor Gray
    
    # Note: This requires SSH keys to be set up for passwordless auth
    # Run: ssh-keygen -t rsa -b 4096
    # Then: ssh-copy-id -p 2222 root@localhost
    
    $session = New-PSSession -HostName $containerHost -Port $sshPort -UserName $sshUser -SSHTransport
    
    if ($null -eq $session) {
        throw "Failed to create PSSession. Make sure SSH keys are configured."
    }
    
    Write-Host "PSSession created successfully!" -ForegroundColor Green
    Write-Host "Session ID: $($session.Id)" -ForegroundColor White
    Write-Host "Computer Name: $($session.ComputerName)" -ForegroundColor White
    Write-Host "State: $($session.State)" -ForegroundColor White
    
    # Example 1: Run basic commands in the remote session
    Write-Host "`n--- Example 1: Basic Remote Commands ---" -ForegroundColor Cyan
    
    $result = Invoke-Command -Session $session -ScriptBlock {
        Get-ChildItem /opt/mssql-tools/bin | Select-Object Name, Length
    }
    
    Write-Host "Files in /opt/mssql-tools/bin:" -ForegroundColor Yellow
    $result | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor White }
    
    # Example 2: Execute SQL query via PSSession
    Write-Host "`n--- Example 2: Execute SQL Query via PSSession ---" -ForegroundColor Cyan
    
    $sqlQuery = "SELECT @@VERSION AS SQLVersion"
    
    $sqlResult = Invoke-Command -Session $session -ScriptBlock {
        param($password, $query)
        
        $output = /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $password -Q $query -h -1
        return $output
    } -ArgumentList $saPassword, $sqlQuery
    
    Write-Host "SQL Server Version:" -ForegroundColor Yellow
    $sqlResult | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 3: Create database via PSSession
    Write-Host "`n--- Example 3: Create Database via PSSession ---" -ForegroundColor Cyan
    
    $createDbQuery = "CREATE DATABASE [$database]"
    
    $createResult = Invoke-Command -Session $session -ScriptBlock {
        param($password, $query)
        
        $output = /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $password -Q $query 2>&1
        return $output
    } -ArgumentList $saPassword, $createDbQuery
    
    Write-Host "Database creation result:" -ForegroundColor Yellow
    $createResult | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 4: Copy file to remote session and execute
    Write-Host "`n--- Example 4: Copy and Execute SQL Script ---" -ForegroundColor Cyan
    
    $sqlScript = @"
USE [$database]
GO

CREATE TABLE TestTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
)
GO

INSERT INTO TestTable (ID, Name) VALUES (1, 'Test Record')
GO

SELECT * FROM TestTable
GO
"@
    
    $scriptResult = Invoke-Command -Session $session -ScriptBlock {
        param($password, $db, $script)
        
        # Save script to file in remote session
        $scriptFile = "/tmp/test-script.sql"
        $script | Out-File -FilePath $scriptFile -Encoding UTF8
        
        # Execute script
        $output = /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $password -i $scriptFile
        
        # Clean up
        Remove-Item $scriptFile
        
        return $output
    } -ArgumentList $saPassword, $database, $sqlScript
    
    Write-Host "Script execution result:" -ForegroundColor Yellow
    $scriptResult | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 5: Get system information
    Write-Host "`n--- Example 5: Remote System Information ---" -ForegroundColor Cyan
    
    $sysInfo = Invoke-Command -Session $session -ScriptBlock {
        [PSCustomObject]@{
            Hostname = hostname
            OSInfo = (cat /etc/os-release | Select-String "PRETTY_NAME" | ForEach-Object { $_ -replace 'PRETTY_NAME=', '' -replace '"', '' })
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            Uptime = uptime -p
        }
    }
    
    Write-Host "Remote System Information:" -ForegroundColor Yellow
    Write-Host "  Hostname: $($sysInfo.Hostname)" -ForegroundColor White
    Write-Host "  OS: $($sysInfo.OSInfo)" -ForegroundColor White
    Write-Host "  PowerShell: $($sysInfo.PowerShellVersion)" -ForegroundColor White
    Write-Host "  Uptime: $($sysInfo.Uptime)" -ForegroundColor White
    
    # Close the session
    Write-Host "`nClosing PSSession..." -ForegroundColor Yellow
    Remove-PSSession -Session $session
    Write-Host "PSSession closed successfully!" -ForegroundColor Green
    
}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    
    if ($_.Exception.Message -like "*key*" -or $_.Exception.Message -like "*auth*") {
        Write-Host "`nSSH Key Setup Required!" -ForegroundColor Yellow
        Write-Host "Run these commands to set up SSH keys:" -ForegroundColor Gray
        Write-Host "  1. ssh-keygen -t rsa -b 4096" -ForegroundColor White
        Write-Host "  2. ssh-copy-id -p 2222 root@localhost" -ForegroundColor White
        Write-Host "  3. Test: ssh root@localhost -p 2222" -ForegroundColor White
    }
    
    if ($session) {
        Remove-PSSession -Session $session -ErrorAction SilentlyContinue
    }
}

Write-Host "`n=== Key PSSession Concepts Demonstrated ===" -ForegroundColor Cyan
Write-Host "✓ Creating persistent remote sessions" -ForegroundColor Green
Write-Host "✓ Executing commands in remote sessions" -ForegroundColor Green
Write-Host "✓ Passing parameters to remote scripts" -ForegroundColor Green
Write-Host "✓ Transferring data between local and remote systems" -ForegroundColor Green
Write-Host "✓ Managing remote session lifecycle" -ForegroundColor Green
