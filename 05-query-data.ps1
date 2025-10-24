# Script to query and display data from SQL Server database

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
    
    $command = $connection.CreateCommand()
    
    # Query 1: All Customers
    Write-Host "`n=== ALL CUSTOMERS ===" -ForegroundColor Yellow
    $command.CommandText = "SELECT CustomerID, FirstName, LastName, Email, Phone, IsActive FROM Customers"
    $reader = $command.ExecuteReader()
    
    while ($reader.Read()) {
        $activeStatus = if ($reader['IsActive']) { "Active" } else { "Inactive" }
        Write-Host "[$($reader['CustomerID'])] $($reader['FirstName']) $($reader['LastName'])" -ForegroundColor Cyan
        Write-Host "  Email: $($reader['Email'])" -ForegroundColor White
        Write-Host "  Phone: $($reader['Phone']) | Status: $activeStatus" -ForegroundColor White
        Write-Host ""
    }
    $reader.Close()
    
    # Query 2: Products by Category
    Write-Host "`n=== PRODUCTS BY CATEGORY ===" -ForegroundColor Yellow
    $command.CommandText = @"
SELECT Category, ProductName, Price, StockQuantity 
FROM Products 
ORDER BY Category, ProductName
"@
    $reader = $command.ExecuteReader()
    
    $currentCategory = ""
    while ($reader.Read()) {
        if ($currentCategory -ne $reader['Category']) {
            $currentCategory = $reader['Category']
            Write-Host "`n[$currentCategory]" -ForegroundColor Cyan
        }
        Write-Host "  $($reader['ProductName'])" -ForegroundColor White
        Write-Host "    Price: `$$($reader['Price']) | Stock: $($reader['StockQuantity'])" -ForegroundColor Gray
    }
    $reader.Close()
    
    # Query 3: Orders with Customer Details
    Write-Host "`n`n=== ORDERS WITH CUSTOMER DETAILS ===" -ForegroundColor Yellow
    $command.CommandText = @"
SELECT 
    o.OrderID, 
    o.OrderDate,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.TotalAmount,
    o.Status,
    o.ShippingAddress
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC
"@
    $reader = $command.ExecuteReader()
    
    while ($reader.Read()) {
        Write-Host "`nOrder #$($reader['OrderID']) - $($reader['Status'])" -ForegroundColor Cyan
        Write-Host "  Customer: $($reader['CustomerName'])" -ForegroundColor White
        Write-Host "  Date: $($reader['OrderDate'])" -ForegroundColor White
        Write-Host "  Total: `$$($reader['TotalAmount'])" -ForegroundColor Green
        Write-Host "  Ship To: $($reader['ShippingAddress'])" -ForegroundColor Gray
    }
    $reader.Close()
    
    # Query 4: Summary Statistics
    Write-Host "`n`n=== SUMMARY STATISTICS ===" -ForegroundColor Yellow
    
    $command.CommandText = "SELECT COUNT(*) FROM Customers WHERE IsActive = 1"
    $activeCustomers = $command.ExecuteScalar()
    Write-Host "Active Customers: $activeCustomers" -ForegroundColor White
    
    $command.CommandText = "SELECT COUNT(DISTINCT Category) FROM Products"
    $categories = $command.ExecuteScalar()
    Write-Host "Product Categories: $categories" -ForegroundColor White
    
    $command.CommandText = "SELECT SUM(TotalAmount) FROM Orders"
    $totalRevenue = $command.ExecuteScalar()
    Write-Host "Total Revenue: `$$totalRevenue" -ForegroundColor Green
    
    $command.CommandText = "SELECT AVG(Price) FROM Products"
    $avgPrice = $command.ExecuteScalar()
    Write-Host "Average Product Price: `$$([math]::Round($avgPrice, 2))" -ForegroundColor White
    
    # Query 5: Orders by Status
    Write-Host "`n=== ORDERS BY STATUS ===" -ForegroundColor Yellow
    $command.CommandText = @"
SELECT Status, COUNT(*) as OrderCount, SUM(TotalAmount) as TotalValue
FROM Orders
GROUP BY Status
ORDER BY OrderCount DESC
"@
    $reader = $command.ExecuteReader()
    
    while ($reader.Read()) {
        Write-Host "$($reader['Status']): $($reader['OrderCount']) orders (`$$($reader['TotalValue']))" -ForegroundColor White
    }
    $reader.Close()
    
    # Query 6: Top Products by Price
    Write-Host "`n=== TOP 5 MOST EXPENSIVE PRODUCTS ===" -ForegroundColor Yellow
    $command.CommandText = @"
SELECT TOP 5 ProductName, Price, Category
FROM Products
ORDER BY Price DESC
"@
    $reader = $command.ExecuteReader()
    
    $rank = 1
    while ($reader.Read()) {
        Write-Host "$rank. $($reader['ProductName']) - `$$($reader['Price']) ($($reader['Category']))" -ForegroundColor White
        $rank++
    }
    $reader.Close()
    
    Write-Host "`n`nQuery completed successfully!" -ForegroundColor Green
    
    $connection.Close()
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
