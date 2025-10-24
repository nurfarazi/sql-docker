# Script to clean up (drop) the test database

$serverInstance = "localhost,1433"
$username = "sa"
$password = "YourStrong!Passw0rd"
$database = "TestDB"

# Connection string (connect to master database to drop TestDB)
$connectionString = "Server=$serverInstance;Database=master;User Id=$username;Password=$password;TrustServerCertificate=True;"

Write-Host "WARNING: This will delete the entire '$database' database!" -ForegroundColor Red
$confirmation = Read-Host "Type 'YES' to confirm deletion"

if ($confirmation -ne 'YES') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

Write-Host "`nConnecting to SQL Server..." -ForegroundColor Cyan

try {
    # Create SQL Connection
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "Connected successfully!" -ForegroundColor Green
    
    # Drop database
    Write-Host "Dropping database '$database'..." -ForegroundColor Cyan
    
    $dropDbQuery = @"
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$database')
BEGIN
    ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE [$database]
    PRINT 'Database dropped successfully'
END
ELSE
BEGIN
    PRINT 'Database does not exist'
END
"@
    
    $command = $connection.CreateCommand()
    $command.CommandText = $dropDbQuery
    $command.ExecuteNonQuery() | Out-Null
    
    Write-Host "Database '$database' has been deleted!" -ForegroundColor Green
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
