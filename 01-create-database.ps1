# Script to create database and tables in SQL Server using PSSession-like approach
# This demonstrates remote command execution similar to PSSession
# Make sure SQL Server container is running before executing this script

$containerName = "sqlwin"
$saPassword = "YourStrong!Passw0rd"
$database = "TestDB"

Write-Host "Connecting to Docker container '$containerName' using remote execution..." -ForegroundColor Cyan
Write-Host "This simulates PSSession by executing commands remotely in the container" -ForegroundColor Gray

try {
    # Verify container is running (similar to testing PSSession connectivity)
    $containerStatus = docker inspect --format='{{.State.Running}}' $containerName 2>$null
    
    if ($containerStatus -ne 'true') {
        throw "Container '$containerName' is not running"
    }
    
    Write-Host "Container is running!" -ForegroundColor Green
    
    # Create Database using sqlcmd via remote execution
    Write-Host "`nCreating database '$database' via remote execution..." -ForegroundColor Cyan
    
    # SQL script to create database and tables
    $createDbScript = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'$database')
BEGIN
    CREATE DATABASE [$database]
    PRINT 'Database created successfully'
END
ELSE
BEGIN
    PRINT 'Database already exists'
END
GO

USE [$database]
GO

-- Create Customers Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Customers] (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        Phone NVARCHAR(20),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    )
    PRINT 'Customers table created'
END
GO

-- Create Orders Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Orders] (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(10,2) NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Pending',
        ShippingAddress NVARCHAR(200)
    )
    PRINT 'Orders table created'
END
GO

-- Create Products Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Products] (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        Price DECIMAL(10,2) NOT NULL,
        StockQuantity INT DEFAULT 0,
        Category NVARCHAR(50),
        CreatedDate DATETIME DEFAULT GETDATE()
    )
    PRINT 'Products table created'
END
GO
"@

    # Save script to temp file locally
    $tempLocalFile = Join-Path $env:TEMP "create-db.sql"
    $createDbScript | Out-File -FilePath $tempLocalFile -Encoding UTF8 -Force
    
    # Copy SQL script to container (similar to copying files in a remote session)
    Write-Host "Copying SQL script to container..." -ForegroundColor Cyan
    docker cp $tempLocalFile ${containerName}:/tmp/create-db.sql
    
    # Execute SQL script inside container (remote execution)
    Write-Host "Executing SQL script remotely in container..." -ForegroundColor Cyan
    $result = docker exec $containerName /opt/mssql-tools/bin/sqlcmd `
        -S localhost `
        -U sa `
        -P $saPassword `
        -i /tmp/create-db.sql
    
    Write-Host "`nSQL Execution Output:" -ForegroundColor Cyan
    $result | ForEach-Object { Write-Host $_ -ForegroundColor White }
    
    # Clean up temp files
    Remove-Item $tempLocalFile -ErrorAction SilentlyContinue
    docker exec $containerName rm /tmp/create-db.sql 2>$null
    
    Write-Host "`nDatabase setup completed successfully!" -ForegroundColor Green
    Write-Host "Database: $database" -ForegroundColor Yellow
    Write-Host "Tables created: Customers, Orders, Products" -ForegroundColor Yellow
    
    Write-Host "`nRemote execution completed." -ForegroundColor Gray
    
    # Switch to new database
    $connection.ChangeDatabase($database)
    
    # Create Customers Table
    Write-Host "Creating Customers table..." -ForegroundColor Cyan
    $createCustomersTable = @"
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Customers] (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        Phone NVARCHAR(20),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    )
    PRINT 'Customers table created'
END
"@
    
    $command.CommandText = $createCustomersTable
    $command.ExecuteNonQuery() | Out-Null
    
    # Create Orders Table
    Write-Host "Creating Orders table..." -ForegroundColor Cyan
    $createOrdersTable = @"
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Orders] (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(10,2) NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Pending',
        ShippingAddress NVARCHAR(200)
    )
    PRINT 'Orders table created'
END
"@
    
    $command.CommandText = $createOrdersTable
    $command.ExecuteNonQuery() | Out-Null
    
    # Create Products Table
    Write-Host "Creating Products table..." -ForegroundColor Cyan
    $createProductsTable = @"
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Products] (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        Price DECIMAL(10,2) NOT NULL,
        StockQuantity INT DEFAULT 0,
        Category NVARCHAR(50),
        CreatedDate DATETIME DEFAULT GETDATE()
    )
    PRINT 'Products table created'
END
"@
    
    $command.CommandText = $createProductsTable
    $command.ExecuteNonQuery() | Out-Null
    
    Write-Host "`nDatabase setup completed successfully!" -ForegroundColor Green
    Write-Host "Database: $database" -ForegroundColor Yellow
    Write-Host "Tables created: Customers, Orders, Products" -ForegroundColor Yellow
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n=== About Remote Execution vs PSSession ===" -ForegroundColor Yellow
Write-Host "This script uses 'docker exec' which works similarly to PSSession:" -ForegroundColor Gray
Write-Host "  - Executes commands on a remote system (the container)" -ForegroundColor Gray
Write-Host "  - Copies files to/from the remote system" -ForegroundColor Gray
Write-Host "  - Returns output from remote execution" -ForegroundColor Gray
Write-Host "`nTo use true PSSession with containers, you need:" -ForegroundColor Gray
Write-Host "  1. SSH server configured in the container" -ForegroundColor Gray
Write-Host "  2. PowerShell Core installed in the container" -ForegroundColor Gray
Write-Host "  3. New-PSSession -HostName containername -UserName user" -ForegroundColor Gray
