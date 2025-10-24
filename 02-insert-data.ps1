# Script to insert sample data into SQL Server database

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
    
    # Insert Customers
    Write-Host "`nInserting sample customers..." -ForegroundColor Cyan
    $insertCustomers = @"
INSERT INTO Customers (FirstName, LastName, Email, Phone, IsActive)
VALUES 
    ('John', 'Doe', 'john.doe@email.com', '555-0101', 1),
    ('Jane', 'Smith', 'jane.smith@email.com', '555-0102', 1),
    ('Michael', 'Johnson', 'michael.j@email.com', '555-0103', 1),
    ('Emily', 'Brown', 'emily.brown@email.com', '555-0104', 1),
    ('David', 'Wilson', 'david.wilson@email.com', '555-0105', 0)
"@
    
    $command = $connection.CreateCommand()
    $command.CommandText = $insertCustomers
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Inserted $rowsAffected customers" -ForegroundColor Green
    
    # Insert Products
    Write-Host "Inserting sample products..." -ForegroundColor Cyan
    $insertProducts = @"
INSERT INTO Products (ProductName, Description, Price, StockQuantity, Category)
VALUES 
    ('Laptop Pro 15', 'High-performance laptop with 16GB RAM', 1299.99, 50, 'Electronics'),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 200, 'Accessories'),
    ('USB-C Cable', '2-meter USB-C charging cable', 15.99, 500, 'Accessories'),
    ('Mechanical Keyboard', 'RGB mechanical gaming keyboard', 89.99, 75, 'Electronics'),
    ('Monitor 27"', '4K Ultra HD 27-inch monitor', 399.99, 30, 'Electronics'),
    ('Desk Lamp', 'LED desk lamp with adjustable brightness', 45.99, 100, 'Office'),
    ('Notebook Set', 'Set of 3 professional notebooks', 12.99, 300, 'Stationery'),
    ('Pen Pack', 'Pack of 10 ballpoint pens', 8.99, 400, 'Stationery')
"@
    
    $command.CommandText = $insertProducts
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Inserted $rowsAffected products" -ForegroundColor Green
    
    # Insert Orders
    Write-Host "Inserting sample orders..." -ForegroundColor Cyan
    $insertOrders = @"
INSERT INTO Orders (CustomerID, TotalAmount, Status, ShippingAddress)
VALUES 
    (1, 1329.98, 'Completed', '123 Main St, New York, NY 10001'),
    (2, 489.98, 'Shipped', '456 Oak Ave, Los Angeles, CA 90001'),
    (3, 399.99, 'Pending', '789 Pine Rd, Chicago, IL 60601'),
    (1, 45.99, 'Completed', '123 Main St, New York, NY 10001'),
    (4, 119.97, 'Processing', '321 Elm St, Houston, TX 77001')
"@
    
    $command.CommandText = $insertOrders
    $rowsAffected = $command.ExecuteNonQuery()
    Write-Host "Inserted $rowsAffected orders" -ForegroundColor Green
    
    # Display summary
    Write-Host "`n--- Database Summary ---" -ForegroundColor Yellow
    
    $command.CommandText = "SELECT COUNT(*) FROM Customers"
    $customerCount = $command.ExecuteScalar()
    Write-Host "Total Customers: $customerCount" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Products"
    $productCount = $command.ExecuteScalar()
    Write-Host "Total Products: $productCount" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(*) FROM Orders"
    $orderCount = $command.ExecuteScalar()
    Write-Host "Total Orders: $orderCount" -ForegroundColor White
    
    Write-Host "`nData insertion completed successfully!" -ForegroundColor Green
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
