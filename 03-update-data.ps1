# Script to update data in SQL Server database

$serverInstance = "localhost,1433"
$username = "sa"
$password = "YourStrong!Passw0rd"
$database = "TestDB"

# Connection string
$connectionString = "Server=$serverInstance;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;"

Write-Host "Connecting to SQL Server database '$database'..." -ForegroundColor Cyan

try {
    # Create SQL Connection
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "Connected successfully!" -ForegroundColor Green
    
    # Update customer email
    Write-Host "`nUpdating customer email..." -ForegroundColor Cyan
    $updateCustomer = @"
UPDATE Customers 
SET Email = 'john.doe.updated@email.com'
WHERE FirstName = 'John' AND LastName = 'Doe'
"@
    
    $command = $connection.CreateCommand()
    $command.CommandText = $updateCustomer
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Updated $rowsAffected customer record(s)" -ForegroundColor Green
    
    # Update product prices (increase by 10%)
    Write-Host "Updating product prices (10% increase on Electronics)..." -ForegroundColor Cyan
    $updateProducts = @"
UPDATE Products 
SET Price = Price * 1.10
WHERE Category = 'Electronics'
"@
    
    $command.CommandText = $updateProducts
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Updated $rowsAffected product record(s)" -ForegroundColor Green
    
    # Update order status
    Write-Host "Updating order status (Pending to Processing)..." -ForegroundColor Cyan
    $updateOrders = @"
UPDATE Orders 
SET Status = 'Processing'
WHERE Status = 'Pending'
"@
    
    $command.CommandText = $updateOrders
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Updated $rowsAffected order record(s)" -ForegroundColor Green
    
    # Update stock quantities
    Write-Host "Updating stock quantities (restocking low items)..." -ForegroundColor Cyan
    $updateStock = @"
UPDATE Products 
SET StockQuantity = StockQuantity + 100
WHERE StockQuantity < 100
"@
    
    $command.CommandText = $updateStock
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Updated $rowsAffected product stock record(s)" -ForegroundColor Green
    
    # Update inactive customers
    Write-Host "Reactivating inactive customers..." -ForegroundColor Cyan
    $updateInactive = @"
UPDATE Customers 
SET IsActive = 1
WHERE IsActive = 0
"@
    
    $command.CommandText = $updateInactive
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Updated $rowsAffected customer status record(s)" -ForegroundColor Green
    
    # Show updated data samples
    Write-Host "`n--- Updated Data Samples ---" -ForegroundColor Yellow
    
    Write-Host "`nUpdated Customer:" -ForegroundColor Cyan
    $command.CommandText = "SELECT TOP 1 FirstName, LastName, Email FROM Customers WHERE LastName = 'Doe'"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "$($reader['FirstName']) $($reader['LastName']): $($reader['Email'])" -ForegroundColor White
    }
    $reader.Close()
    
    Write-Host "`nElectronics Products (with updated prices):" -ForegroundColor Cyan
    $command.CommandText = "SELECT ProductName, Price, Category FROM Products WHERE Category = 'Electronics'"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "$($reader['ProductName']): `$$($reader['Price']) - $($reader['Category'])" -ForegroundColor White
    }
    $reader.Close()
    
    Write-Host "`nOrder Status Summary:" -ForegroundColor Cyan
    $command.CommandText = "SELECT Status, COUNT(*) as Count FROM Orders GROUP BY Status"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "$($reader['Status']): $($reader['Count']) orders" -ForegroundColor White
    }
    $reader.Close()
    
    Write-Host "`nData update completed successfully!" -ForegroundColor Green
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
