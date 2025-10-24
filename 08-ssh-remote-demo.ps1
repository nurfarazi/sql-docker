# Remote SQL Server management using SSH commands
# Demonstrates remote execution concepts similar to PSSession

$containerHost = "localhost"
$sshPort = 2222
$sshUser = "root"
$saPassword = "YourStrong!Passw0rd"
$database = "TestDB"

Write-Host "=== Remote SQL Server Management via SSH ===" -ForegroundColor Cyan
Write-Host "Using direct SSH commands for remote execution`n" -ForegroundColor Gray

try {
    # Example 1: System Information
    Write-Host "--- Example 1: Remote System Information ---" -ForegroundColor Cyan
    
    Write-Host "Getting hostname..." -ForegroundColor Yellow
    $hostname = ssh -p $sshPort "${sshUser}@${containerHost}" "hostname"
    Write-Host "Hostname: $hostname" -ForegroundColor White
    
    # Example 2: SQL Server Version
    Write-Host "`n--- Example 2: SQL Server Version ---" -ForegroundColor Cyan
    
    Write-Host "Querying SQL Server..." -ForegroundColor Yellow
    $sqlCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -Q ""SELECT @@VERSION"" -h -1"
    $sqlVersion = ssh -p $sshPort "${sshUser}@${containerHost}" $sqlCmd
    Write-Host $sqlVersion -ForegroundColor White
    
    # Example 3: Create Database
    Write-Host "`n--- Example 3: Create Database ---" -ForegroundColor Cyan
    
    Write-Host "Creating database '$database'..." -ForegroundColor Yellow
    $createDbCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -Q ""IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$database') CREATE DATABASE [$database]"""
    ssh -p $sshPort "${sshUser}@${containerHost}" $createDbCmd | Out-Null
    Write-Host "Database created!" -ForegroundColor Green
    
    # Example 4: Create Table
    Write-Host "`n--- Example 4: Create Table ---" -ForegroundColor Cyan
    
    $createTableSQL = @"
USE [$database];
CREATE TABLE RemoteTest (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Message NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE()
);
"@
    
    # Save script locally
    $tempScript = Join-Path $env:TEMP "create-table.sql"
    $createTableSQL | Out-File -FilePath $tempScript -Encoding UTF8 -Force
    
    # Copy to container
    Write-Host "Copying SQL script to container..." -ForegroundColor Yellow
    scp -P $sshPort $tempScript "${sshUser}@${containerHost}:/tmp/create-table.sql" 2>$null
    
    # Execute
    Write-Host "Executing SQL script..." -ForegroundColor Yellow
    $execCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -i /tmp/create-table.sql"
    ssh -p $sshPort "${sshUser}@${containerHost}" $execCmd
    
    # Cleanup
    ssh -p $sshPort "${sshUser}@${containerHost}" "rm /tmp/create-table.sql" 2>$null
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    Write-Host "Table created!" -ForegroundColor Green
    
    # Example 5: Insert Data
    Write-Host "`n--- Example 5: Insert Data ---" -ForegroundColor Cyan
    
    Write-Host "Inserting test records..." -ForegroundColor Yellow
    $insertCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -Q ""USE [$database]; INSERT INTO RemoteTest (Message) VALUES ('Hello from SSH'), ('Remote execution'), ('Learning PowerShell')"""
    ssh -p $sshPort "${sshUser}@${containerHost}" $insertCmd | Out-Null
    Write-Host "3 records inserted!" -ForegroundColor Green
    
    # Example 6: Query Data
    Write-Host "`n--- Example 6: Query Data ---" -ForegroundColor Cyan
    
    Write-Host "Querying RemoteTest table..." -ForegroundColor Yellow
    $queryCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -d $database -Q ""SELECT * FROM RemoteTest"" -s ""|"""
    $results = ssh -p $sshPort "${sshUser}@${containerHost}" $queryCmd
    
    Write-Host "`nResults:" -ForegroundColor Yellow
    $results | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 7: Update Data
    Write-Host "`n--- Example 7: Update Data ---" -ForegroundColor Cyan
    
    Write-Host "Updating record..." -ForegroundColor Yellow
    $updateCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -Q ""USE [$database]; UPDATE RemoteTest SET Message = Message + ' (Updated)' WHERE ID = 1"""
    ssh -p $sshPort "${sshUser}@${containerHost}" $updateCmd | Out-Null
    Write-Host "Record updated!" -ForegroundColor Green
    
    # Example 8: Delete Data
    Write-Host "`n--- Example 8: Delete Data ---" -ForegroundColor Cyan
    
    Write-Host "Deleting record..." -ForegroundColor Yellow
    $deleteCmd = "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $saPassword -Q ""USE [$database]; DELETE FROM RemoteTest WHERE ID = 2"""
    ssh -p $sshPort "${sshUser}@${containerHost}" $deleteCmd | Out-Null
    Write-Host "Record deleted!" -ForegroundColor Green
    
    # Example 9: Final Query
    Write-Host "`n--- Example 9: Final Data State ---" -ForegroundColor Cyan
    
    Write-Host "Querying final state..." -ForegroundColor Yellow
    $finalResults = ssh -p $sshPort "${sshUser}@${containerHost}" $queryCmd
    
    Write-Host "`nFinal Records:" -ForegroundColor Yellow
    $finalResults | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    Write-Host "`n✓ All remote operations completed successfully!" -ForegroundColor Green
    
}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
}

Write-Host "`n=== What You Learned ===" -ForegroundColor Cyan
Write-Host "✓ Remote command execution via SSH" -ForegroundColor Green
Write-Host "✓ Secure file copy (scp)" -ForegroundColor Green
Write-Host "✓ Remote SQL operations (CREATE, INSERT, UPDATE, DELETE, SELECT)" -ForegroundColor Green
Write-Host "✓ Script execution on remote systems" -ForegroundColor Green

Write-Host "`nThese same concepts apply to PSSession:" -ForegroundColor Yellow
Write-Host "  ssh command        = Invoke-Command -ScriptBlock {}" -ForegroundColor Gray
Write-Host "  scp file           = Copy-Item -ToSession" -ForegroundColor Gray
Write-Host "  Multiple commands  = New-PSSession (persistent connection)" -ForegroundColor Gray
