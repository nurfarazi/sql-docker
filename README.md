# 🚀 SQL Server Docker Automation Lab

A comprehensive, hands-on PowerShell laboratory project demonstrating enterprise-grade SQL Server database operations, containerization, remote execution, and SSH-based management within Docker environments.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Purpose & Learning Objectives](#purpose--learning-objectives)
- [Technical Stack](#technical-stack)
- [Project Architecture](#project-architecture)
- [Getting Started](#getting-started)
- [Core Learning Modules](#core-learning-modules)
- [Advanced Topics](#advanced-topics)
- [Database Schema](#database-schema)
- [Scripts Breakdown](#scripts-breakdown)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Troubleshooting & Common Scenarios](#troubleshooting--common-scenarios)

---

## 🎯 Project Overview

This repository is a **multi-layered educational and practical platform** that combines:

- **Container Orchestration**: Docker-based SQL Server environments
- **Infrastructure as Code**: Dockerfiles with custom configurations
- **Database Administration**: Full CRUD operations with real-world scenarios
- **Remote System Management**: SSH-based container access and PowerShell Remoting
- **Infrastructure Automation**: End-to-end scripted workflows
- **Security Patterns**: SSH key authentication, credential management, and secure connections

The project evolves from basic database operations to advanced remote execution scenarios, making it suitable for:
- **DevOps Engineers**: Learning containerization and remote management
- **Database Administrators**: Understanding SQL Server in Docker environments
- **PowerShell Developers**: Mastering automation, remoting, and error handling
- **System Administrators**: Managing containerized services at scale

---

## 🎓 Purpose & Learning Objectives

### What You Can Do

1. **Deploy SQL Server Environments**: Rapidly spin up isolated SQL Server instances using Docker
2. **Automate Database Operations**: Write idempotent scripts that create, populate, and manage databases
3. **Perform CRUD Operations**: Execute Create, Read, Update, Delete operations programmatically
4. **Generate Reports**: Query complex data relationships and export results
5. **Access Containers Remotely**: Connect to containers via SSH and PowerShell Remoting
6. **Manage Multiple Environments**: Handle local and remote SQL Server instances
7. **Implement Infrastructure Automation**: Build repeatable, reliable deployment pipelines
8. **Practice Git Workflows**: Version-control infrastructure and scripts

### What You'll Learn

#### **Core Competencies**
- **PowerShell Mastery**: 
  - Scripting patterns (functions, error handling, logging)
  - SqlServer module usage for database operations
  - Remote execution with `Invoke-Command` and `New-PSSession`
  - Parameter validation and secure credential handling
  
- **Docker Fundamentals**:
  - Dockerfile syntax and image layering
  - Container lifecycle management
  - Port mapping and networking
  - Volume persistence and bind mounts
  - Multi-service container orchestration (SSH + SQL Server)

- **SQL Server Administration**:
  - T-SQL DDL (CREATE, ALTER, DROP)
  - T-SQL DML (INSERT, UPDATE, DELETE, SELECT)
  - Schema design with relationships and constraints
  - Transaction management and error handling
  - Query optimization and performance patterns

- **Linux in Containers**:
  - Ubuntu package management (apt-get)
  - SSH server configuration and security
  - Process management (systemctl/service)
  - File permissions and user management

#### **Advanced Concepts**
- **Security**:
  - SSH key-based authentication vs. password authentication
  - Secure credential storage and retrieval
  - SQL Server authentication modes (Mixed)
  - Network security in containerized environments

- **Remote Management**:
  - PowerShell Remoting over SSH
  - Session management and lifecycle
  - Script blocks and parameter passing in remote contexts
  - Debugging remote execution issues

- **Infrastructure as Code (IaC)**:
  - Declarative infrastructure definitions
  - Idempotent script design
  - Version control for infrastructure
  - CI/CD integration patterns

- **Error Handling & Reliability**:
  - Try-catch blocks in PowerShell
  - Connection retry logic
  - Graceful degradation
  - Logging and troubleshooting strategies

---

## 🛠️ Technical Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **Docker** | Latest | Container runtime and orchestration |
| **SQL Server** | 2019 | Enterprise database engine |
| **PowerShell** | 7.x (in container) / 5.x+ (local) | Scripting and automation |
| **OpenSSH** | Latest | Secure remote access |
| **Ubuntu** | 20.04 (base) | Container OS for SSH variant |
| **Git** | Latest | Version control |

---

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Development Machine                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         PowerShell Scripts (Automation Layer)        │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │  01-05: Database Operations  │  06-09: Remote Mgmt  │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│     ┌─────────────────────┴──────────────────────┐          │
│     │                                             │          │
│     ▼                                             ▼          │
│  ┌─────────────────┐                  ┌──────────────────┐  │
│  │  Dockerfile     │                  │ Dockerfile.ssh   │  │
│  │  (Basic SQL)    │                  │ (SQL + SSH)      │  │
│  └─────────────────┘                  └──────────────────┘  │
│     │                                             │          │
│     └─────────────────────┬──────────────────────┘          │
│                           ▼                                  │
│     ┌─────────────────────────────────────────┐             │
│     │      Docker Container Runtime (Linux)   │             │
│     ├─────────────────────────────────────────┤             │
│     │  ┌─────────────────┐    ┌─────────────┐│             │
│     │  │  SQL Server     │    │ SSH Server  ││             │
│     │  │  (Port 1433)    │    │ (Port 2222) ││             │
│     │  └─────────────────┘    └─────────────┘│             │
│     │  ┌─────────────────┐    ┌─────────────┐│             │
│     │  │  PowerShell 7.x │    │   Ubuntu OS ││             │
│     │  └─────────────────┘    └─────────────┘│             │
│     └─────────────────────────────────────────┘             │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

#### **Local Machine Setup**
```powershell
# 1. Install Docker Desktop for Windows
#    - Enable WSL 2 backend
#    - Switch to Linux containers mode

# 2. Verify Docker installation
docker version
docker ps

# 3. Verify PowerShell (5.1 or 7.x)
$PSVersionTable.PSVersion

# 4. Clone this repository
git clone <repo-url>
cd sql-docker
```

#### **Quick Start: Basic SQL Server Container**

```powershell
# 1. Build the basic SQL Server image
docker build -t sqlserver2019 -f Dockerfile .

# 2. Run the container
docker run -d `
  --name sqlserver-container `
  -p 1433:1433 `
  -e "ACCEPT_EULA=Y" `
  -e "SA_PASSWORD=YourStrong!Passw0rd" `
  sqlserver2019

# 3. Verify container is running
docker ps

# 4. Execute database scripts in order
.\01-create-database.ps1
.\02-insert-data.ps1
.\05-query-data.ps1
```

#### **Advanced Setup: SSH-Enabled Container**

```powershell
# 1. Build the SSH-enabled SQL Server image
docker build -t sqlserver2019-ssh -f Dockerfile.ssh .

# 2. Setup SSH keys (one-time)
.\00-setup-ssh-container.ps1

# 3. Run the SSH-enabled container
docker run -d `
  --name sqlserver-ssh `
  -p 1433:1433 `
  -p 2222:22 `
  -e "ACCEPT_EULA=Y" `
  -e "SA_PASSWORD=YourStrong!Passw0rd" `
  sqlserver2019-ssh

# 4. Copy SSH keys to container
.\00b-copy-ssh-key.ps1

# 5. Test remote access
.\06-pssession-examples.ps1
```

---

## 📚 Core Learning Modules

### **Module 1: Database Fundamentals (Scripts 01-05)**

Learn foundational SQL and PowerShell by working with a realistic e-commerce database schema.

#### **01-create-database.ps1** - Schema Design
- **Concepts**: SQL DDL, table creation, primary/foreign keys, constraints, indexing
- **Skills Developed**:
  - Connecting to SQL Server from PowerShell
  - Executing T-SQL statements programmatically
  - Error handling for schema conflicts
  - Understanding relational database design
- **Real-World Application**: Database migration projects, infrastructure provisioning

#### **02-insert-data.ps1** - Data Population
- **Concepts**: SQL DML, bulk inserts, transaction management
- **Skills Developed**:
  - Working with data sets in PowerShell
  - Building SQL INSERT statements dynamically
  - Transaction safety and rollback
  - Batch operations for performance
- **Real-World Application**: ETL processes, data seeding, testing data generation

#### **03-update-data.ps1** - Data Modification
- **Concepts**: UPDATE statements, WHERE clauses, partial updates
- **Skills Developed**:
  - Conditional data updates
  - Multi-table updates with JOIN
  - Logging changes for audit trails
  - Validating updates with pre/post checks
- **Real-World Application**: Data corrections, bulk modifications, archival updates

#### **04-delete-data.ps1** - Data Cleanup
- **Concepts**: DELETE statements, cascading deletes, soft deletes
- **Skills Developed**:
  - Safe deletion with verification
  - Referential integrity constraints
  - Soft delete patterns (logical vs. physical)
  - Backup strategies before destructive operations
- **Real-World Application**: Data retention policies, GDPR compliance, database cleanup

#### **05-query-data.ps1** - Reporting & Analysis
- **Concepts**: SELECT queries, JOINs, aggregations, grouping, sorting
- **Skills Developed**:
  - Complex SQL queries with multiple joins
  - Data aggregation and reporting
  - Result formatting for presentation
  - Performance consideration in queries
- **Real-World Application**: Business analytics, dashboard data retrieval, audit reporting

---

### **Module 2: Container Management (Dockerfile & Dockerfile.ssh)**

Master Docker fundamentals by building and customizing containerized SQL Server environments.

#### **Dockerfile** - Basic Configuration
```dockerfile
FROM mcr.microsoft.com/mssql/server:2019-latest
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong!Passw0rd
EXPOSE 1433
```

**Learning Points**:
- Base image selection and compatibility
- Environment variable injection
- Port exposure and container networking
- Layering and caching optimization

**Practical Exercise**: Modify the Dockerfile to:
- Use a different SQL Server version
- Add custom startup scripts
- Change default ports
- Include additional tools

#### **Dockerfile.ssh** - Advanced Configuration
```dockerfile
FROM mcr.microsoft.com/mssql/server:2019-latest
USER root
RUN apt-get update && apt-get install -y openssh-server powershell
# ... SSH configuration
EXPOSE 1433 22
CMD service ssh start && /opt/mssql/bin/sqlservr
```

**Learning Points**:
- Multi-stage Dockerfile patterns
- Package management in Linux containers
- Service orchestration (running multiple services)
- User context and permissions
- Port multiplexing

**Advanced Challenge**: 
- Create a health check endpoint
- Implement signal handling for graceful shutdown
- Add monitoring/logging infrastructure

---

### **Module 3: Remote Management Fundamentals (Scripts 06-09)**

Progress from basic remote execution to sophisticated PowerShell Remoting patterns.

#### **06-pssession-examples.ps1** - PowerShell Remoting Basics
- **Concepts**: PSSession lifecycle, SSH transport, remote execution
- **Skills Developed**:
  - Creating and managing persistent sessions
  - Error handling in remote contexts
  - Variable scoping in remote blocks
  - Session cleanup and resource management
- **Real-World Application**: Remote server administration, distributed task execution

#### **07-remote-execution-ssh.ps1** - SSH-Based Commands
- **Concepts**: SSH authentication, Invoke-Command, parameter passing
- **Skills Developed**:
  - SSH key management and authentication
  - Command piping over SSH
  - Working with standard streams (stdout, stderr)
  - Performance considerations for remote operations
- **Real-World Application**: Cross-platform automation, Linux administration from Windows

#### **08-ssh-remote-demo.ps1** - Practical SSH Integration
- **Concepts**: SSH connection strings, timeout handling, credential management
- **Skills Developed**:
  - Connection pooling and reuse
  - Retry logic with exponential backoff
  - Secure credential passing
  - Comprehensive error reporting
- **Real-World Application**: Production deployments, CI/CD pipelines, runbooks

#### **09-remote-execution-demo.ps1** - End-to-End Scenarios
- **Concepts**: Orchestrating multi-step remote operations
- **Skills Developed**:
  - Workflow automation
  - Dependency management between steps
  - Parallel execution with `ForEach-Object -Parallel`
  - Result aggregation and reporting
- **Real-World Application**: Infrastructure automation, disaster recovery procedures

---

## 🔬 Advanced Topics

### **Topic 1: SSH Configuration & Security**

**Understanding SSH in Containers**:
```bash
# SSH Server Configuration
/etc/ssh/sshd_config

# Key aspects:
- PermitRootLogin settings
- Authentication methods (key vs. password)
- Port configuration
- Secure defaults
```

**Hands-On**: 
- Generate RSA keypairs with different sizes
- Configure key-based authentication
- Implement SSH agent for key management
- Analyze security implications of different configurations

### **Topic 2: PowerShell Remoting Protocol**

**Protocol Comparison**:
| Transport | Protocol | Security | Latency | Use Case |
|-----------|----------|----------|---------|----------|
| WinRM | HTTP/HTTPS | TLS | Higher | Windows-to-Windows |
| SSH | SSH | ED25519/RSA | Lower | Cross-platform |
| Direct | TCP | None | Lowest | Local debugging |

**Deep Dive**: 
- Trace protocol conversations with WireShark
- Understand session negotiation
- Compare bandwidth consumption
- Optimize for your use case

### **Topic 3: SQL Server on Linux Differences**

**What Changes in Linux Containers**:
- File paths: Windows backslashes → Unix forward slashes
- Service management: `sqlservr` process instead of Windows service
- Authentication: SQL authentication instead of Windows Auth (mostly)
- Networking: Different port binding syntax
- Permissions: Linux file permissions, user context

**Practical Exercise**:
- Connect to running SQL Server container
- Execute queries from Linux command line
- Understand filesystem differences
- Debug permission issues

### **Topic 4: Idempotent Script Design**

**Pattern**: Scripts should be safely re-runnable without side effects.

**Implementation**:
```powershell
# Good: Check before creating
if (-not (Invoke-Sqlcmd -Query "SELECT DB_ID('TestDB')")) {
    # Create only if doesn't exist
}

# Better: Use IF NOT EXISTS in T-SQL
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name='TestDB') CREATE DATABASE TestDB"
```

### **Topic 5: Error Handling & Resilience**

**Patterns Demonstrated**:
- Try-catch-finally blocks
- Retry logic with exponential backoff
- Graceful degradation
- Comprehensive logging
- Alert conditions and thresholds

---

## 📊 Database Schema

### **Conceptual Diagram**

```
┌─────────────────────┐         ┌─────────────────────┐
│    CUSTOMERS        │         │     PRODUCTS        │
├─────────────────────┤         ├─────────────────────┤
│ CustomerID (PK)     │         │ ProductID (PK)      │
│ FirstName           │         │ ProductName         │
│ LastName            │         │ Description         │
│ Email (UNIQUE)      │         │ Price (DECIMAL)     │
│ Phone               │         │ StockQuantity (INT) │
│ CreatedDate         │         │ Category            │
│ IsActive (BIT)      │         │ CreatedDate         │
└─────────────────────┘         └─────────────────────┘
         ▲                                  ▲
         │                                  │
         └──────────┬──────────────────────┘
                    │
                    │ 1:N Relationship
                    │
           ┌────────▼────────┐
           │     ORDERS      │
           ├─────────────────┤
           │ OrderID (PK)    │
           │ CustomerID (FK) │
           │ OrderDate       │
           │ TotalAmount     │
           │ Status          │
           │ ShippingAddr    │
           └─────────────────┘
```

### **Detailed Schema**

```sql
-- CUSTOMERS TABLE
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
CREATE INDEX idx_Customer_Email ON Customers(Email);

-- PRODUCTS TABLE
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    Category NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
);
CREATE INDEX idx_Product_Category ON Products(Category);

-- ORDERS TABLE (Fact Table)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    Quantity INT NOT NULL DEFAULT 1,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Pending',
    ShippingAddress NVARCHAR(200),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
CREATE INDEX idx_Order_CustomerID ON Orders(CustomerID);
CREATE INDEX idx_Order_Status ON Orders(Status);
```

---

## 📜 Scripts Breakdown

### **Setup & Initialization**

| Script | Purpose | Key Learning |
|--------|---------|--------------|
| `00-setup-ssh-container.ps1` | Configure SSH infrastructure | SSH key generation, Docker exec, service management |
| `00b-copy-ssh-key.ps1` | Deploy SSH credentials | Secure file transfer, Docker cp command |

### **Core CRUD Operations**

| Script | Purpose | Complexity | Estimated Time |
|--------|---------|-----------|-----------------|
| `01-create-database.ps1` | Initialize schema | Beginner | 5 min |
| `02-insert-data.ps1` | Populate with sample data | Beginner | 5 min |
| `03-update-data.ps1` | Modify existing records | Intermediate | 10 min |
| `04-delete-data.ps1` | Remove records safely | Intermediate | 10 min |
| `05-query-data.ps1` | Generate reports | Intermediate | 15 min |

### **Remote Management**

| Script | Purpose | Complexity | Prerequisites |
|--------|---------|-----------|-----------------|
| `06-pssession-examples.ps1` | PSSession with SSH transport | Advanced | SSH keys configured |
| `07-remote-execution-ssh.ps1` | Invoke-Command patterns | Advanced | SSH connectivity |
| `08-ssh-remote-demo.ps1` | SSH connection management | Advanced | SSH keys configured |
| `09-remote-execution-demo.ps1` | End-to-end automation | Expert | All previous prerequisites |

### **Maintenance**

| Script | Purpose | Warning |
|--------|---------|---------|
| `99-cleanup-database.ps1` | Drop entire database | **DESTRUCTIVE** - verify before running |

---

## ✅ Best Practices Demonstrated

### **PowerShell Conventions**
- ✅ Descriptive variable names
- ✅ Comment-based help documentation
- ✅ Comprehensive error handling
- ✅ Logging and output formatting
- ✅ Credential security (not hardcoded where possible)

### **Docker Best Practices**
- ✅ Multi-stage builds
- ✅ Minimal base images
- ✅ Health check implementation
- ✅ Proper signal handling (ENTRYPOINT vs CMD)
- ✅ Environment variable injection

### **SQL Server Administration**
- ✅ Transaction management
- ✅ Backup/restore considerations
- ✅ Proper indexing strategies
- ✅ Constraint enforcement
- ✅ Security (SA account password management)

### **Infrastructure as Code**
- ✅ Idempotent scripts
- ✅ Version control for infrastructure
- ✅ Documentation of all manual steps
- ✅ Automated testing possible
- ✅ Reproducible environments

---

## 🔧 Troubleshooting & Common Scenarios

### **Scenario 1: Cannot Connect to SQL Server**

**Error**: `A network-related or instance-specific error occurred...`

**Diagnosis & Solutions**:
```powershell
# 1. Verify container is running
docker ps | Select-Object Names, Ports

# 2. Check SQL Server logs
docker logs sqlserver-container

# 3. Test connection from container
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourPassword" -Q "SELECT @@VERSION"

# 4. Verify port mapping
docker inspect sqlserver-container | Select-Object -ExpandProperty HostConfig | Select-Object PortBindings
```

### **Scenario 2: SSH Connection Fails**

**Error**: `Permission denied (publickey)`

**Diagnosis & Solutions**:
```powershell
# 1. Verify SSH server is running in container
docker exec sqlserver-ssh ps aux | grep sshd

# 2. Check SSH key permissions
ls -la ~/.ssh/

# 3. Verify public key is in container
docker exec sqlserver-ssh cat /root/.ssh/authorized_keys

# 4. Test SSH connection with verbose output
ssh -vvv -p 2222 root@localhost

# 5. Common fix: Regenerate keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### **Scenario 3: Database Script Fails with Timeout**

**Error**: `Timeout expired. The timeout period elapsed...`

**Solutions**:
```powershell
# Increase timeout in scripts:
$connection.ConnectionTimeout = 30  # seconds
$connection.CommandTimeout = 300    # seconds

# Or use Invoke-Sqlcmd with timeout parameter:
Invoke-Sqlcmd -Query "SELECT ..." -ConnectionTimeout 30 -QueryTimeout 300
```

### **Scenario 4: Container Disk Space Full**

**Error**: `No space left on device`

**Resolution**:
```powershell
# Check container disk usage
docker exec sqlserver-container df -h

# Remove unused containers and images
docker system prune -a

# Or increase container storage limit when creating container
docker run --storage-opt size=50G ...
```

### **Scenario 5: PowerShell Remoting Over SSH Not Working**

**Error**: `Unable to connect to remote server...`

**Debug Steps**:
```powershell
# 1. Check SSH connectivity first
ssh -p 2222 root@localhost "echo 'SSH works'"

# 2. Verify PowerShell is installed in container
docker exec sqlserver-ssh pwsh -Version

# 3. Check SSH subsystem configuration
docker exec sqlserver-ssh grep Subsystem /etc/ssh/sshd_config

# 4. Test with explicit parameters
New-PSSession -HostName localhost -Port 2222 -UserName root -SSHTransport -Verbose
```

### **Useful Diagnostic Commands**

```powershell
# Get container resource usage
docker stats sqlserver-container

# Inspect container configuration
docker inspect sqlserver-container

# View container network
docker network inspect bridge

# Execute interactive bash in container
docker exec -it sqlserver-container /bin/bash

# Stream container logs in real-time
docker logs -f sqlserver-container

# Check connection to SQL Server
Test-NetConnection -ComputerName localhost -Port 1433

# Verify PowerShell module installation
Get-Module SqlServer -ListAvailable
```

---

## 🎓 Learning Paths

### **Path 1: Database Administrator**
1. Complete scripts 01-05
2. Study Database Schema section
3. Modify queries in 05-query-data.ps1
4. Create custom stored procedures
5. Implement backup/restore procedures

### **Path 2: DevOps / Infrastructure**
1. Study both Dockerfiles thoroughly
2. Complete scripts 06-09
3. Set up CI/CD pipeline with these scripts
4. Implement infrastructure monitoring
5. Create Kubernetes manifests from Docker setup

### **Path 3: PowerShell Developer**
1. Analyze script structure and error handling
2. Complete all scripts in sequence
3. Refactor scripts using functions and modules
4. Implement logging framework
5. Create Pester tests for scripts

### **Path 4: Full-Stack DevOps**
1. Complete all three paths above
2. Create comprehensive documentation
3. Build automated testing suite
4. Implement secret management (Azure Key Vault)
5. Create production-ready deployment templates

---

## 📖 Additional Resources

### **Official Documentation**
- [Microsoft SQL Server on Linux](https://docs.microsoft.com/sql/linux)
- [Docker SQL Server Images](https://hub.docker.com/_/microsoft-mssql-server)
- [PowerShell SqlServer Module](https://docs.microsoft.com/powershell/module/sqlserver)
- [SSH Transport for PowerShell Remoting](https://docs.microsoft.com/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core)

### **Learning Materials**
- T-SQL Tutorial: [W3Schools SQL](https://www.w3schools.com/sql/)
- Docker Deep Dive: [Docker Documentation](https://docs.docker.com/)
- PowerShell Advanced: [Microsoft Learn - PowerShell](https://learn.microsoft.com/powershell/)

---

## ⚖️ License & Contributing

This project is maintained as an educational resource. Feel free to:
- Fork and extend for your learning
- Submit pull requests with improvements
- Create issues for questions or problems
- Share with colleagues and students

---

## 📞 Support & Questions

For issues or questions:
1. Check the **Troubleshooting** section above
2. Review script comments for inline documentation
3. Examine Docker logs: `docker logs <container-name>`
4. Create GitHub issue with detailed error logs

---

**Last Updated**: October 2025  
**Project Status**: Active Development & Learning Resource
docker exec -it sqlwin /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd"
```

## Notes

- All scripts use `TrustServerCertificate=True` for development/testing purposes
- Change the password in production environments
- Scripts include error handling and colored output for better readability
- The cleanup script requires confirmation before deleting the database
