# Script to delete data from SQL Server database

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
    
    # Show counts before deletion
    Write-Host "`n--- Before Deletion ---" -ForegroundColor Yellow
    $command = $connection.CreateCommand()
    
    $command.CommandText = "SELECT COUNT(*) FROM Orders"
    $orderCount = $command.ExecuteScalar()
    Write-Host "Orders: $orderCount" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Customers"
    $customerCount = $command.ExecuteScalar()
    Write-Host "Customers: $customerCount" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Products"
    $productCount = $command.ExecuteScalar()
    Write-Host "Products: $productCount" -ForegroundColor White
    
    # Delete completed orders older than a certain date
    Write-Host "`nDeleting completed orders..." -ForegroundColor Cyan
    $deleteOrders = @"
DELETE FROM Orders 
WHERE Status = 'Completed'
"@
    
    $command.CommandText = $deleteOrders
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Deleted $rowsAffected completed order(s)" -ForegroundColor Green
    
    # Delete products with zero stock
    Write-Host "Deleting out-of-stock products..." -ForegroundColor Cyan
    $deleteProducts = @"
DELETE FROM Products 
WHERE StockQuantity = 0
"@
    
    $command.CommandText = $deleteProducts
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Deleted $rowsAffected out-of-stock product(s)" -ForegroundColor Green
    
    # Delete a specific customer (who has no orders)
    Write-Host "Deleting inactive customers with no orders..." -ForegroundColor Cyan
    $deleteCustomers = @"
DELETE FROM Customers 
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders)
AND IsActive = 0
"@
    
    $command.CommandText = $deleteCustomers
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Deleted $rowsAffected inactive customer(s) with no orders" -ForegroundColor Green
    
    # Show counts after deletion
    Write-Host "`n--- After Deletion ---" -ForegroundColor Yellow
    
    $command.CommandText = "SELECT COUNT(*) FROM Orders"
    $orderCountAfter = $command.ExecuteScalar()
    Write-Host "Orders: $orderCountAfter (deleted: $($orderCount - $orderCountAfter))" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Customers"
    $customerCountAfter = $command.ExecuteScalar()
    Write-Host "Customers: $customerCountAfter (deleted: $($customerCount - $customerCountAfter))" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Products"
    $productCountAfter = $command.ExecuteScalar()
    Write-Host "Products: $productCountAfter (deleted: $($productCount - $productCountAfter))" -ForegroundColor White
    
    # Show remaining data
    Write-Host "`n--- Remaining Orders ---" -ForegroundColor Yellow
    $command.CommandText = "SELECT OrderID, CustomerID, Status, TotalAmount FROM Orders"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Order #$($reader['OrderID']): Customer $($reader['CustomerID']) - $($reader['Status']) - `$$($reader['TotalAmount'])" -ForegroundColor White
    }
    $reader.Close()
    
    Write-Host "`nData deletion completed successfully!" -ForegroundColor Green
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
