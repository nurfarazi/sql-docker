# Simple PSSession-style remote execution using SSH (works without PowerShell subsystem)
# This demonstrates remote execution concepts similar to PSSession

$containerHost = "localhost"
$sshPort = 2222
$sshUser = "root"
$saPassword = "YourStrong!Passw0rd"
$database = "TestDB"

Write-Host "=== Demonstrating Remote Execution via SSH (PSSession Concepts) ===" -ForegroundColor Cyan
Write-Host "Using Invoke-Command over SSH for remote execution`n" -ForegroundColor Gray

try {
    # Example 1: Basic remote command execution
    Write-Host "--- Example 1: Execute Remote Commands ---" -ForegroundColor Yellow
    
    $result = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        "Hostname: $(hostname)"
        "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
        "PowerShell Version: $($PSVersionTable.PSVersion)"
    }
    
    Write-Host $result -ForegroundColor White
    
    # Example 2: Check SQL Server status
    Write-Host "`n--- Example 2: Check SQL Server Status ---" -ForegroundColor Yellow
    
    $sqlStatus = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd)
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -Q "SELECT @@VERSION" -h -1
    } -ArgumentList $saPassword
    
    Write-Host "SQL Server Version:" -ForegroundColor Cyan
    Write-Host $sqlStatus -ForegroundColor White
    
    # Example 3: Create Database
    Write-Host "`n--- Example 3: Create Database via Remote Execution ---" -ForegroundColor Yellow
    
    $createDb = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$db') CREATE DATABASE [$db]"
    } -ArgumentList $saPassword, $database
    
    Write-Host "Database created: $database" -ForegroundColor Green
    
    # Example 4: Create Table
    Write-Host "`n--- Example 4: Create Table ---" -ForegroundColor Yellow
    
    $createTable = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        
        $sql = @"
USE [$db]
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RemoteTest]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[RemoteTest] (
        ID INT PRIMARY KEY IDENTITY(1,1),
        Message NVARCHAR(100),
        CreatedDate DATETIME DEFAULT GETDATE()
    )
END
"@
        
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -Q $sql
    } -ArgumentList $saPassword, $database
    
    Write-Host "Table 'RemoteTest' created" -ForegroundColor Green
    
    # Example 5: Insert Data
    Write-Host "`n--- Example 5: Insert Data via Remote Execution ---" -ForegroundColor Yellow
    
    $insertData = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        
        $sql = @"
USE [$db]
INSERT INTO RemoteTest (Message) VALUES ('Hello from PSSession!')
INSERT INTO RemoteTest (Message) VALUES ('Remote execution works!')
INSERT INTO RemoteTest (Message) VALUES ('Learning PowerShell remoting')
"@
        
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -Q $sql
    } -ArgumentList $saPassword, $database
    
    Write-Host "Data inserted successfully" -ForegroundColor Green
    
    # Example 6: Query Data
    Write-Host "`n--- Example 6: Query Data ---" -ForegroundColor Yellow
    
    $queryData = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -d $db -Q "SELECT ID, Message, CreatedDate FROM RemoteTest" -s "|"
    } -ArgumentList $saPassword, $database
    
    Write-Host "Query Results:" -ForegroundColor Cyan
    $queryData | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 7: Execute SQL Script File
    Write-Host "`n--- Example 7: Execute SQL Script from Remote Session ---" -ForegroundColor Yellow
    
    $scriptResult = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        
        # Create SQL script in remote session
        $script = @"
USE [$db]
GO

-- Update records
UPDATE RemoteTest SET Message = Message + ' (Updated)' WHERE ID = 1
GO

-- Query updated data
SELECT 'Updated Records:' AS Info
SELECT ID, Message FROM RemoteTest
GO

-- Summary
SELECT 'Total Records:' AS Info, COUNT(*) AS Count FROM RemoteTest
GO
"@
        
        # Save to temp file
        $scriptFile = "/tmp/remote-script.sql"
        $script | Out-File -FilePath $scriptFile -Encoding UTF8
        
        # Execute script
        $output = /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -i $scriptFile
        
        # Clean up
        Remove-Item $scriptFile -ErrorAction SilentlyContinue
        
        return $output
    } -ArgumentList $saPassword, $database
    
    Write-Host "Script execution results:" -ForegroundColor Cyan
    $scriptResult | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Example 8: Get Database Statistics
    Write-Host "`n--- Example 8: Database Statistics ---" -ForegroundColor Yellow
    
    $stats = Invoke-Command -HostName $containerHost -Port $sshPort -UserName $sshUser -ScriptBlock {
        param($pwd, $db)
        
        $sql = @"
USE [$db]
SELECT 
    'Database' = DB_NAME(),
    'Tables' = COUNT(DISTINCT t.name),
    'Total Rows' = SUM(p.rows)
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
"@
        
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $pwd -Q $sql -h -1
    } -ArgumentList $saPassword, $database
    
    Write-Host "Database Statistics:" -ForegroundColor Cyan
    $stats | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    Write-Host "`n✓ All remote execution examples completed successfully!" -ForegroundColor Green
    
}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
}

Write-Host "`n=== Key Concepts Demonstrated ===" -ForegroundColor Cyan
Write-Host "✓ Remote command execution via SSH" -ForegroundColor Green
Write-Host "✓ Passing parameters to remote scripts" -ForegroundColor Green
Write-Host "✓ Creating and executing SQL scripts remotely" -ForegroundColor Green
Write-Host "✓ Querying and manipulating remote databases" -ForegroundColor Green
Write-Host "✓ Managing remote files and cleanup" -ForegroundColor Green

Write-Host "`n=== Invoke-Command vs New-PSSession ===" -ForegroundColor Yellow
Write-Host "Invoke-Command: Creates temporary connection for each command" -ForegroundColor Gray
Write-Host "New-PSSession: Creates persistent reusable session" -ForegroundColor Gray
Write-Host "`nBoth use the same remoting infrastructure and concepts!" -ForegroundColor White
