# Simple remote execution demo using the working sqlwin container (via docker exec)
# This demonstrates the same concepts as PSSession

$containerName = "sqlwin"
$saPassword = "YourStrong!Passw0rd"
$database = "TestDB"

Write-Host "=== Remote SQL Server Management Demo ===" -ForegroundColor Cyan
Write-Host "Using docker exec (simulates remote execution like PSSession)`n" -ForegroundColor Gray

try {
    # Example 1: System Information
    Write-Host "--- Example 1: Remote System Information ---" -ForegroundColor Cyan
    
    Write-Host "Getting container hostname..." -ForegroundColor Yellow
    $hostname = docker exec $containerName hostname
    Write-Host "Hostname: $hostname" -ForegroundColor White
    
    Write-Host "Getting OS info..." -ForegroundColor Yellow
    $os = docker exec $containerName cat /etc/os-release | Select-String "PRETTY_NAME"
    Write-Host "OS: $os" -ForegroundColor White
    
    # Example 2: SQL Server Version
    Write-Host "`n--- Example 2: SQL Server Version ---" -ForegroundColor Cyan
    
    Write-Host "Querying SQL Server version..." -ForegroundColor Yellow
    $sqlVersion = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q "SELECT @@VERSION" -h -1
    Write-Host $sqlVersion -ForegroundColor White
    
    # Example 3: Create Database
    Write-Host "`n--- Example 3: Create Database ---" -ForegroundColor Cyan
    
    Write-Host "Creating database '$database'..." -ForegroundColor Yellow
    docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword `
        -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$database') CREATE DATABASE [$database]" | Out-Null
    Write-Host "Database '$database' created!" -ForegroundColor Green
    
    # Example 4: Create Table
    Write-Host "`n--- Example 4: Create Table ---" -ForegroundColor Cyan
    
    $createTableSQL = @"
USE [$database];
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RemoteTest]'))
CREATE TABLE RemoteTest (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Message NVARCHAR(100),
    CreatedBy NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
);
"@
    
    # Save locally
    $tempScript = Join-Path $env:TEMP "create-table.sql"
    $createTableSQL | Out-File -FilePath $tempScript -Encoding UTF8 -Force
    
    # Copy to container (like scp in PSSession)
    Write-Host "Copying SQL script to container..." -ForegroundColor Yellow
    docker cp $tempScript ${containerName}:/tmp/create-table.sql
    
    # Execute (like Invoke-Command in PSSession)
    Write-Host "Executing SQL script remotely..." -ForegroundColor Yellow
    docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -i /tmp/create-table.sql
    
    # Cleanup
    docker exec $containerName rm /tmp/create-table.sql 2>$null
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    Write-Host "Table created!" -ForegroundColor Green
    
    # Example 5: Insert Data
    Write-Host "`n--- Example 5: Insert Data ---" -ForegroundColor Cyan
    
    Write-Host "Inserting test records..." -ForegroundColor Yellow
    docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q `
        "USE [$database]; INSERT INTO RemoteTest (Message, CreatedBy) VALUES ('Hello from Docker!', 'PowerShell'), ('Remote execution works!', 'Windows Host'), ('Learning remoting concepts', 'Local Machine')" | Out-Null
    Write-Host "3 records inserted!" -ForegroundColor Green
    
    # Example 6: Query Data
    Write-Host "`n--- Example 6: Query Data ---" -ForegroundColor Cyan
    
    Write-Host "Querying RemoteTest table..." -ForegroundColor Yellow
    $results = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword `
        -d $database -Q "SELECT ID, Message, CreatedBy FROM RemoteTest" -s "|"
    
    Write-Host "`nResults:" -ForegroundColor Yellow
    $results | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 7: Update Data
    Write-Host "`n--- Example 7: Update Data ---" -ForegroundColor Cyan
    
    Write-Host "Updating first record..." -ForegroundColor Yellow
    docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q `
        "USE [$database]; UPDATE RemoteTest SET Message = Message + ' (Modified)' WHERE ID = 1" | Out-Null
    Write-Host "Record updated!" -ForegroundColor Green
    
    # Example 8: Delete Data
    Write-Host "`n--- Example 8: Delete Data ---" -ForegroundColor Cyan
    
    Write-Host "Deleting second record..." -ForegroundColor Yellow
    docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q `
        "USE [$database]; DELETE FROM RemoteTest WHERE ID = 2" | Out-Null
    Write-Host "Record deleted!" -ForegroundColor Green
    
    # Example 9: Final Query
    Write-Host "`n--- Example 9: Final Data State ---" -ForegroundColor Cyan
    
    Write-Host "Querying remaining records..." -ForegroundColor Yellow
    $finalResults = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword `
        -d $database -Q "SELECT ID, Message, CreatedBy, CONVERT(VARCHAR, CreatedDate, 120) AS Created FROM RemoteTest" -s "|"
    
    Write-Host "`nRemaining Records:" -ForegroundColor Yellow
    $finalResults | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 10: Database Statistics
    Write-Host "`n--- Example 10: Database Statistics ---" -ForegroundColor Cyan
    
    Write-Host "Getting database stats..." -ForegroundColor Yellow
    $stats = docker exec $containerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $saPassword -Q `
        "USE [$database]; SELECT 'Total Tables' = COUNT(*), 'Total Records' = (SELECT COUNT(*) FROM RemoteTest) FROM sys.tables"
    
    Write-Host $stats -ForegroundColor White
    
    Write-Host "`n✓ All remote operations completed successfully!" -ForegroundColor Green
    
}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
}

Write-Host "`n=== Remote Execution Concepts Learned ===" -ForegroundColor Cyan
Write-Host "✓ Remote command execution" -ForegroundColor Green
Write-Host "✓ File transfer to remote system" -ForegroundColor Green
Write-Host "✓ Remote SQL operations (CREATE, INSERT, UPDATE, DELETE, SELECT)" -ForegroundColor Green
Write-Host "✓ Script execution on remote system" -ForegroundColor Green
Write-Host "✓ Data retrieval from remote system" -ForegroundColor Green

Write-Host "`n=== How This Relates to PSSession ===" -ForegroundColor Yellow
Write-Host "docker exec container command     = Invoke-Command -ScriptBlock {command}" -ForegroundColor Gray
Write-Host "docker cp file container:/path    = Copy-Item -ToSession `$session" -ForegroundColor Gray
Write-Host "Multiple docker exec commands     = New-PSSession (persistent session)" -ForegroundColor Gray

Write-Host "`nYou've learned the core concepts of remote PowerShell execution!" -ForegroundColor White
