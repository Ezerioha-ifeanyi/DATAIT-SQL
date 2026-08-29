
/* ============================================================================
   DataIT Beginner SQL Course — FMCG Distribution Dataset (SQL Server)
   Tables: Agents, Retailers, SalesOrders, SalesOrderLines, Payments
   Includes: seed data generator (70+ rows per table), views, stored procedures,
            and solution queries to the 50 project questions.
   ============================================================================ */

-- 0) Create DB (optional)
IF DB_ID('DataIT_FMCG') IS NULL
BEGIN
    CREATE DATABASE DataIT_FMCG;
END
GO
USE DataIT_FMCG;
GO

-- 1) Drop existing objects (safe reset for re-runs)
IF OBJECT_ID('dbo.Payments','U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.SalesOrderLines','U') IS NOT NULL DROP TABLE dbo.SalesOrderLines;
IF OBJECT_ID('dbo.SalesOrders','U') IS NOT NULL DROP TABLE dbo.SalesOrders;
IF OBJECT_ID('dbo.Retailers','U') IS NOT NULL DROP TABLE dbo.Retailers;
IF OBJECT_ID('dbo.Agents','U') IS NOT NULL DROP TABLE dbo.Agents;
GO

-- 2) Create tables
CREATE TABLE dbo.Agents (
    AgentID      INT IDENTITY(1,1) PRIMARY KEY,
    AgentCode    VARCHAR(20) NOT NULL UNIQUE,
    FullName     VARCHAR(120) NOT NULL,
    Phone        VARCHAR(20)  NULL,
    HomeState    VARCHAR(60)  NULL,
    HomeCity     VARCHAR(80)  NULL,
    Role         VARCHAR(40)  NOT NULL,  -- e.g., Sales Agent, City Head
    HireDate     DATE         NOT NULL,
    Status       VARCHAR(20)  NOT NULL   -- Active, Suspended, Exited
);
GO

CREATE TABLE dbo.Retailers (
    RetailerID         INT IDENTITY(1,1) PRIMARY KEY,
    BusinessName       VARCHAR(150) NOT NULL,
    OwnerName          VARCHAR(120) NULL,
    Phone              VARCHAR(20)  NULL,
    Channel            VARCHAR(40)  NOT NULL, -- Retail, HoReCa, Supermarket, Pharmacy, etc.
    PaymentPreference  VARCHAR(30)  NOT NULL, -- Cash, Transfer, Wallet, POS
    CreditLimit        DECIMAL(18,2) NOT NULL DEFAULT(0),
    StateName          VARCHAR(80)  NOT NULL,
    CityName           VARCHAR(80)  NOT NULL,
    AddressLine        VARCHAR(200) NULL,
    CreatedAt          DATE         NOT NULL
);
GO

CREATE TABLE dbo.SalesOrders (
    OrderID         INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber     VARCHAR(30) NOT NULL UNIQUE,
    RetailerID      INT NOT NULL,
    AgentID         INT NULL,  -- allow NULL to support "missing agent" join questions
    OrderDate       DATETIME2 NOT NULL,
    FulfillmentType VARCHAR(20) NOT NULL, -- Delivery, SelfPickup
    StockPoint      VARCHAR(120) NOT NULL, -- e.g., OmniHub Agege Lagos - Deobell
    Status          VARCHAR(20) NOT NULL,  -- Created, Confirmed, Packed, Dispatched, Delivered, Cancelled
    CancelReason    VARCHAR(200) NULL,
    NetAmount       DECIMAL(18,2) NOT NULL DEFAULT(0),
    LastUpdatedAt   DATETIME2 NULL,
    CONSTRAINT FK_SalesOrders_Retailers FOREIGN KEY (RetailerID) REFERENCES dbo.Retailers(RetailerID),
    CONSTRAINT FK_SalesOrders_Agents    FOREIGN KEY (AgentID)    REFERENCES dbo.Agents(AgentID)
);
GO

CREATE TABLE dbo.SalesOrderLines (
    LineID      INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL,
    SKUCode     VARCHAR(30) NOT NULL,
    SKUName     VARCHAR(200) NOT NULL,
    Category    VARCHAR(80) NOT NULL,
    UOM         VARCHAR(20) NOT NULL,  -- Carton, Pack, Piece
    Qty         INT NOT NULL,
    UnitPrice   DECIMAL(18,2) NOT NULL,
    LineTotal   AS (CONVERT(DECIMAL(18,2), Qty * UnitPrice)) PERSISTED,
    CONSTRAINT FK_OrderLines_Orders FOREIGN KEY (OrderID) REFERENCES dbo.SalesOrders(OrderID)
);
GO

CREATE TABLE dbo.Payments (
    PaymentID   INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL,
    PaymentDate DATETIME2 NOT NULL,
    Amount      DECIMAL(18,2) NOT NULL,
    Method      VARCHAR(20) NOT NULL,  -- Cash, Transfer, Wallet, POS
    Reference   VARCHAR(60) NOT NULL UNIQUE,
    Status      VARCHAR(20) NOT NULL,  -- Pending, Confirmed, Reversed
    CreatedAt   DATETIME2 NOT NULL DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES dbo.SalesOrders(OrderID)
);
GO

CREATE INDEX IX_SalesOrders_OrderDate ON dbo.SalesOrders(OrderDate);
CREATE INDEX IX_SalesOrders_Status    ON dbo.SalesOrders(Status);
CREATE INDEX IX_OrderLines_OrderID    ON dbo.SalesOrderLines(OrderID);
CREATE INDEX IX_Payments_OrderID      ON dbo.Payments(OrderID);
GO

/* 3) Seed data generator
   Goal: 70+ rows per table. You can re-run the script safely (drops tables first).
*/
-- 3a) Agents (25)
INSERT INTO dbo.Agents (AgentCode, FullName, Phone, HomeState, HomeCity, Role, HireDate, Status)
VALUES
('AGT001','Azeez Gbadamosi','08030000001','Lagos','Agege','Sales Agent','2024-02-10','Active'),
('AGT002','Edidiong Akpan','08030000002','Lagos','Ikeja','Sales Agent','2023-10-12','Active'),
('AGT003','Bola Adebayo','08030000003','Abuja FCT','Garki','City Head','2022-06-03','Active'),
('AGT004','Grace Okafor','08030000004','Rivers','Port Harcourt','Sales Agent','2024-01-19','Active'),
('AGT005','Ibrahim Musa','08030000005','Kano','Nasarawa','Sales Agent','2023-08-07','Active'),
('AGT006','Tomi Aluko','08030000006','Oyo','Ibadan','Sales Agent','2022-11-22','Active'),
('AGT007','Chidinma Eze','08030000007','Enugu','Nsukka','Sales Agent','2023-03-15','Suspended'),
('AGT008','Sani Bello','08030000008','Kaduna','Zaria','Sales Agent','2021-09-30','Active'),
('AGT009','Fatima Yusuf','08030000009','Abuja FCT','Wuse','Sales Agent','2024-05-09','Active'),
('AGT010','Kehinde Adeyemi','08030000010','Lagos','Ifako-Ijaiye','City Head','2020-04-18','Active'),
('AGT011','Mary Johnson','08030000011','Lagos','Surulere','Sales Agent','2023-12-01','Active'),
('AGT012','Samuel Nwosu','08030000012','Anambra','Awka','Sales Agent','2022-05-21','Active'),
('AGT013','Hauwa Abdullahi','08030000013','Katsina','Katsina','Sales Agent','2021-01-14','Active'),
('AGT014','Olaoluwa Sanya','08030000014','Lagos','Yaba','Sales Agent','2024-03-05','Active'),
('AGT015','Blessing Udo','08030000015','Akwa Ibom','Uyo','Sales Agent','2023-07-27','Active'),
('AGT016','Musa Abdallah','08030000016','Abuja FCT','Kubwa','Sales Agent','2022-02-17','Active'),
('AGT017','Ifeanyi Obi','08030000017','Imo','Owerri','Sales Agent','2021-12-09','Active'),
('AGT018','Damilola Ade','08030000018','Lagos','Alimosho','Sales Agent','2024-06-11','Active'),
('AGT019','Nneka Nnamdi','08030000019','Delta','Warri','Sales Agent','2023-04-23','Active'),
('AGT020','Kabir Lawal','08030000020','Lagos','Ikorodu','Sales Agent','2022-10-02','Active'),
('AGT021','Ngozi Nwankwo','08030000021','Abia','Umuahia','Sales Agent','2020-07-13','Exited'),
('AGT022','Yusuf Garba','08030000022','Kwara','Ilorin','Sales Agent','2023-09-08','Active'),
('AGT023','Zainab Ibrahim','08030000023','Lagos','Ajah','Sales Agent','2024-07-01','Active'),
('AGT024','Temitope Ajayi','08030000024','Ogun','Abeokuta','Sales Agent','2022-03-28','Active'),
('AGT025','Efe Oghene','08030000025','Edo','Benin','Sales Agent','2023-01-20','Active');
GO

-- 3b) Retailers (80) using a tally table
WITH N AS (
  SELECT TOP (80) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO dbo.Retailers (BusinessName, OwnerName, Phone, Channel, PaymentPreference, CreditLimit, StateName, CityName, AddressLine, CreatedAt)
SELECT
  CONCAT('Retailer ', n, ' Stores') AS BusinessName,
  CONCAT('Owner ', n) AS OwnerName,
  CONCAT('0804', RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)) AS Phone,
  CASE WHEN n%5=0 THEN 'Supermarket'
       WHEN n%5=1 THEN 'Retail'
       WHEN n%5=2 THEN 'HoReCa'
       WHEN n%5=3 THEN 'Pharmacy'
       ELSE 'Wholesaler' END AS Channel,
  CASE WHEN n%4=0 THEN 'Transfer'
       WHEN n%4=1 THEN 'Cash'
       WHEN n%4=2 THEN 'Wallet'
       ELSE 'POS' END AS PaymentPreference,
  CAST( (50000 + (n*3500) + (n%7)*12000) AS DECIMAL(18,2)) AS CreditLimit,
  CASE WHEN n%4=0 THEN 'Lagos'
       WHEN n%4=1 THEN 'Abuja FCT'
       WHEN n%4=2 THEN 'Rivers'
       ELSE 'Kano' END AS StateName,
  CASE WHEN n%4=0 THEN 'Ikeja'
       WHEN n%4=1 THEN 'Wuse'
       WHEN n%4=2 THEN 'Port Harcourt'
       ELSE 'Nasarawa' END AS CityName,
  CONCAT('No. ', n, ' Market Road') AS AddressLine,
  DATEADD(DAY, - (n*9), CAST(GETDATE() AS DATE)) AS CreatedAt
FROM N;
GO

-- 3c) SalesOrders (120) round-robin retailers + agents
WITH N AS (
  SELECT TOP (120) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
),
R AS (
  SELECT RetailerID, ROW_NUMBER() OVER (ORDER BY RetailerID) AS rn FROM dbo.Retailers
),
A AS (
  SELECT AgentID, ROW_NUMBER() OVER (ORDER BY AgentID) AS rn FROM dbo.Agents
)
INSERT INTO dbo.SalesOrders (OrderNumber, RetailerID, AgentID, OrderDate, FulfillmentType, StockPoint, Status, CancelReason, NetAmount, LastUpdatedAt)
SELECT
  CONCAT('SO-', FORMAT(GETDATE(),'yyMMdd'), '-', RIGHT('0000' + CAST(n AS VARCHAR(4)), 4)) AS OrderNumber,
  (SELECT RetailerID FROM R WHERE rn = ((n-1)%80)+1),
  CASE WHEN n%23=0 THEN NULL ELSE (SELECT AgentID FROM A WHERE rn = ((n-1)%25)+1) END AS AgentID,
  DATEADD(HOUR, (n%12), DATEADD(DAY, -(n%45), CAST(GETDATE() AS DATETIME2))) AS OrderDate,
  CASE WHEN n%3=0 THEN 'SelfPickup' ELSE 'Delivery' END AS FulfillmentType,
  CASE WHEN n%4=0 THEN 'OmniHub Agege Lagos - Deobell'
       WHEN n%4=1 THEN 'OmniHub Ifako Ijaiye Lagos - Bickson'
       WHEN n%4=2 THEN 'OmniHub AMAC Abuja - Elriah'
       ELSE 'OmniHub PHC Rivers - Docks' END AS StockPoint,
  CASE WHEN n%10=0 THEN 'Cancelled'
       WHEN n%10 IN (1,2) THEN 'Created'
       WHEN n%10 IN (3,4) THEN 'Confirmed'
       WHEN n%10=5 THEN 'Packed'
       WHEN n%10=6 THEN 'Dispatched'
       ELSE 'Delivered' END AS Status,
  CASE WHEN n%10=0 THEN 'Customer requested cancellation' ELSE NULL END AS CancelReason,
  0 AS NetAmount,
  SYSDATETIME() AS LastUpdatedAt
FROM N;
GO

-- 3d) SalesOrderLines (>= 300 lines) using a small SKU catalog
DECLARE @Sku TABLE (SKUCode VARCHAR(30), SKUName VARCHAR(200), Category VARCHAR(80), BasePrice DECIMAL(18,2));
INSERT INTO @Sku VALUES
('SKU001','Indomie Regular Chicken 70g','Noodles',9400),
('SKU002','Dano Cool Cow Sachet 12g','Dairy',6500),
('SKU003','Munch It Creamy Crunch 25g','Snacks',7200),
('SKU004','Rice 5kg','Grains',18500),
('SKU005','Energy Drink 50cl','Beverages',12500),
('SKU006','Tomato Paste 210g','Condiments',9800),
('SKU007','Laundry Detergent 1kg','Home Care',16200),
('SKU008','Bottled Water 75cl','Beverages',8800),
('SKU009','Chocolate Wafer 30g','Snacks',5400),
('SKU010','Sardines 125g','Canned Foods',7600);

;WITH O AS (
  SELECT OrderID, ROW_NUMBER() OVER (ORDER BY OrderID) AS rn
  FROM dbo.SalesOrders
),
N AS (
  SELECT TOP (350) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
),
Pick AS (
  SELECT
    n,
    (SELECT OrderID FROM O WHERE rn = ((n-1)%120)+1) AS OrderID,
    (SELECT TOP 1 SKUCode FROM @Sku ORDER BY ABS(CHECKSUM(NEWID()))) AS SKUCode
  FROM N
)
INSERT INTO dbo.SalesOrderLines (OrderID, SKUCode, SKUName, Category, UOM, Qty, UnitPrice)
SELECT
  p.OrderID,
  s.SKUCode,
  s.SKUName,
  s.Category,
  CASE WHEN p.n%3=0 THEN 'Carton' WHEN p.n%3=1 THEN 'Pack' ELSE 'Piece' END AS UOM,
  (1 + (p.n%8)) AS Qty,
  CAST( s.BasePrice * (CASE WHEN p.n%5=0 THEN 1.05 WHEN p.n%5=1 THEN 0.95 ELSE 1.00 END) AS DECIMAL(18,2)) AS UnitPrice
FROM Pick p
JOIN @Sku s ON s.SKUCode = p.SKUCode;
GO

-- Update NetAmount per order from lines
UPDATE o
SET o.NetAmount = x.TotalLines
FROM dbo.SalesOrders o
JOIN (
  SELECT OrderID, SUM(LineTotal) AS TotalLines
  FROM dbo.SalesOrderLines
  GROUP BY OrderID
) x ON x.OrderID = o.OrderID;
GO

-- 3e) Payments (140) with partial / pending / reversed mix
WITH O AS (
  SELECT TOP (140) OrderID, OrderNumber, NetAmount, OrderDate,
         ROW_NUMBER() OVER (ORDER BY OrderID) AS rn
  FROM dbo.SalesOrders
  WHERE Status IN ('Delivered','Dispatched','Confirmed','Created')  -- include some unpaid delivered for practice
),
N AS (
  SELECT TOP (140) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO dbo.Payments (OrderID, PaymentDate, Amount, Method, Reference, Status)
SELECT
  o.OrderID,
  DATEADD(DAY, (n%5), o.OrderDate) AS PaymentDate,
  CAST(
      CASE WHEN n%7=0 THEN o.NetAmount * 0.50  -- partial
           WHEN n%11=0 THEN o.NetAmount * 1.00
           ELSE o.NetAmount * 0.80 END
    AS DECIMAL(18,2)) AS Amount,
  CASE WHEN n%4=0 THEN 'Transfer' WHEN n%4=1 THEN 'Cash' WHEN n%4=2 THEN 'Wallet' ELSE 'POS' END AS Method,
  CONCAT('PAY-', FORMAT(GETDATE(),'yyMMdd'), '-', RIGHT('00000' + CAST(n AS VARCHAR(5)), 5)) AS Reference,
  CASE WHEN n%13=0 THEN 'Reversed'
       WHEN n%5=0 THEN 'Pending'
       ELSE 'Confirmed' END AS Status
FROM O o
JOIN N n ON n.n = o.rn;
GO

/* ============================================================================
   4) Views (per project questions)
   ============================================================================ */
IF OBJECT_ID('dbo.vw_RetailerOrderStats','V') IS NOT NULL DROP VIEW dbo.vw_RetailerOrderStats;
GO
CREATE VIEW dbo.vw_RetailerOrderStats AS
SELECT
  r.RetailerID,
  r.BusinessName,
  COUNT(o.OrderID) AS TotalOrders,
  SUM(CASE WHEN o.Status='Delivered' THEN 1 ELSE 0 END) AS DeliveredOrders,
  SUM(CASE WHEN o.Status='Delivered' THEN o.NetAmount ELSE 0 END) AS DeliveredGMV
FROM dbo.Retailers r
LEFT JOIN dbo.SalesOrders o ON o.RetailerID = r.RetailerID
GROUP BY r.RetailerID, r.BusinessName;
GO

IF OBJECT_ID('dbo.vw_OrderBasket','V') IS NOT NULL DROP VIEW dbo.vw_OrderBasket;
GO
CREATE VIEW dbo.vw_OrderBasket AS
SELECT
  o.OrderNumber,
  l.SKUName,
  l.Category,
  l.UOM,
  l.Qty,
  l.UnitPrice,
  l.LineTotal
FROM dbo.SalesOrders o
JOIN dbo.SalesOrderLines l ON l.OrderID = o.OrderID;
GO

/* ============================================================================
   5) Stored Procedures (per project questions)
   ============================================================================ */
IF OBJECT_ID('dbo.usp_SetAgentStatus','P') IS NOT NULL DROP PROCEDURE dbo.usp_SetAgentStatus;
GO
CREATE PROCEDURE dbo.usp_SetAgentStatus
  @AgentCode VARCHAR(20),
  @NewStatus VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE dbo.Agents
  SET Status = @NewStatus
  WHERE AgentCode = @AgentCode;

  SELECT * FROM dbo.Agents WHERE AgentCode = @AgentCode;
END;
GO

IF OBJECT_ID('dbo.usp_CreateOrderHeader','P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateOrderHeader;
GO
CREATE PROCEDURE dbo.usp_CreateOrderHeader
  @RetailerID INT,
  @AgentID INT,
  @FulfillmentType VARCHAR(20),
  @StockPoint VARCHAR(120)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @OrderNumber VARCHAR(30) =
    CONCAT('SO-', FORMAT(GETDATE(),'yyMMdd'), '-', RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID()))%10000 AS VARCHAR(4)),4));

  INSERT INTO dbo.SalesOrders (OrderNumber, RetailerID, AgentID, OrderDate, FulfillmentType, StockPoint, Status, NetAmount, LastUpdatedAt)
  VALUES (@OrderNumber, @RetailerID, @AgentID, SYSDATETIME(), @FulfillmentType, @StockPoint, 'Created', 0, SYSDATETIME());

  SELECT * FROM dbo.SalesOrders WHERE OrderNumber = @OrderNumber;
END;
GO

IF OBJECT_ID('dbo.usp_AddPayment','P') IS NOT NULL DROP PROCEDURE dbo.usp_AddPayment;
GO
CREATE PROCEDURE dbo.usp_AddPayment
  @OrderNumber VARCHAR(30),
  @Amount DECIMAL(18,2),
  @Method VARCHAR(20),
  @Reference VARCHAR(60)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @OrderID INT;

  SELECT @OrderID = OrderID
  FROM dbo.SalesOrders
  WHERE OrderNumber = @OrderNumber;

  IF @OrderID IS NULL
  BEGIN
    RAISERROR('OrderNumber not found.', 16, 1);
    RETURN;
  END

  INSERT INTO dbo.Payments (OrderID, PaymentDate, Amount, Method, Reference, Status)
  VALUES (@OrderID, SYSDATETIME(), @Amount, @Method, @Reference, 'Pending');

  ;WITH Paid AS (
    SELECT OrderID, SUM(CASE WHEN Status='Confirmed' THEN Amount ELSE 0 END) AS ConfirmedPaid
    FROM dbo.Payments
    WHERE OrderID = @OrderID
    GROUP BY OrderID
  )
  SELECT
    o.OrderNumber,
    o.NetAmount,
    ISNULL(p.ConfirmedPaid,0) AS TotalConfirmedPaid,
    (o.NetAmount - ISNULL(p.ConfirmedPaid,0)) AS Outstanding
  FROM dbo.SalesOrders o
  LEFT JOIN Paid p ON p.OrderID = o.OrderID
  WHERE o.OrderID = @OrderID;
END;
GO

/* ============================================================================
   6) SOLUTION QUERIES — 50 Project Questions (grouped by table)
   Use these as instructor keys or as “after you try” solutions.
   ============================================================================ */

-- A) Agents (10)
-- A1 CRUD Create: Insert a new agent
INSERT INTO dbo.Agents (AgentCode, FullName, Phone, HomeState, HomeCity, Role, HireDate, Status)
VALUES ('AGT999','Test Agent','08039999999','Lagos','Ikeja','Sales Agent', CAST(GETDATE() AS DATE), 'Active');

-- A2 CRUD Update: Set an agent’s Status to Suspended by AgentCode
UPDATE dbo.Agents SET Status='Suspended' WHERE AgentCode='AGT999';

-- A3 CRUD Delete: Delete agents with Status='Exited' only if they have no orders in SalesOrders
DELETE a
FROM dbo.Agents a
WHERE a.Status='Exited'
  AND NOT EXISTS (SELECT 1 FROM dbo.SalesOrders o WHERE o.AgentID = a.AgentID);

-- A4 Sorting: List the 10 most recently hired agents
SELECT TOP 10 * FROM dbo.Agents ORDER BY HireDate DESC;

-- A5 Aggregate: Count agents by Role
SELECT Role, COUNT(*) AS AgentCount
FROM dbo.Agents
GROUP BY Role
ORDER BY AgentCount DESC;

-- A6 Group By + Having: Show HomeState with more than 5 active agents
SELECT HomeState, COUNT(*) AS ActiveAgents
FROM dbo.Agents
WHERE Status='Active'
GROUP BY HomeState
HAVING COUNT(*) > 5
ORDER BY ActiveAgents DESC;

-- A7 Inner Join: For each agent, total delivered GMV
SELECT a.AgentID, a.FullName, SUM(o.NetAmount) AS DeliveredGMV
FROM dbo.Agents a
JOIN dbo.SalesOrders o ON o.AgentID = a.AgentID
WHERE o.Status='Delivered'
GROUP BY a.AgentID, a.FullName
ORDER BY DeliveredGMV DESC;

-- A8 Left Join: Agents who have never delivered an order
SELECT a.*
FROM dbo.Agents a
LEFT JOIN dbo.SalesOrders o
  ON o.AgentID = a.AgentID AND o.Status='Delivered'
WHERE o.OrderID IS NULL;

-- A9 Right Join: All orders even if agent is missing (RIGHT JOIN)
SELECT o.OrderNumber, o.Status, o.NetAmount, a.FullName AS AgentName
FROM dbo.Agents a
RIGHT JOIN dbo.SalesOrders o ON o.AgentID = a.AgentID
ORDER BY o.OrderDate DESC;

-- A10 Stored Procedure: usp_SetAgentStatus
EXEC dbo.usp_SetAgentStatus @AgentCode='AGT999', @NewStatus='Active';

-- B) Retailers (10)
-- B1 CRUD Create: Insert a new retailer with Lagos address and Transfer preference
INSERT INTO dbo.Retailers (BusinessName, OwnerName, Phone, Channel, PaymentPreference, CreditLimit, StateName, CityName, AddressLine, CreatedAt)
VALUES ('New Lagos Retailer','Kemi Lagos','08050000000','Retail','Transfer',150000,'Lagos','Ikeja','12 Allen Avenue', CAST(GETDATE() AS DATE));

-- B2 CRUD Update: Increase CreditLimit by 15% for Channel='Supermarket'
UPDATE dbo.Retailers
SET CreditLimit = CreditLimit * 1.15
WHERE Channel='Supermarket';

-- B3 CRUD Delete: Delete retailers created over 2 years ago only if they have no orders
DELETE r
FROM dbo.Retailers r
WHERE r.CreatedAt < DATEADD(YEAR,-2, CAST(GETDATE() AS DATE))
  AND NOT EXISTS (SELECT 1 FROM dbo.SalesOrders o WHERE o.RetailerID = r.RetailerID);

-- B4 Sorting: Top 20 retailers by CreditLimit
SELECT TOP 20 RetailerID, BusinessName, CreditLimit
FROM dbo.Retailers
ORDER BY CreditLimit DESC;

-- B5 Aggregate: Count retailers by Channel
SELECT Channel, COUNT(*) AS RetailerCount
FROM dbo.Retailers
GROUP BY Channel
ORDER BY RetailerCount DESC;

-- B6 Group By: For each StateName, number of retailers and avg credit limit
SELECT StateName, COUNT(*) AS RetailerCount, AVG(CreditLimit) AS AvgCreditLimit
FROM dbo.Retailers
GROUP BY StateName
ORDER BY RetailerCount DESC;

-- B7 Inner Join: Retailers with total number of orders placed
SELECT r.BusinessName, COUNT(o.OrderID) AS TotalOrders
FROM dbo.Retailers r
JOIN dbo.SalesOrders o ON o.RetailerID = r.RetailerID
GROUP BY r.BusinessName
ORDER BY TotalOrders DESC;

-- B8 Left Join: Retailers who never placed an order
SELECT r.*
FROM dbo.Retailers r
LEFT JOIN dbo.SalesOrders o ON o.RetailerID = r.RetailerID
WHERE o.OrderID IS NULL;

-- B9 Join + Filter: HoReCa retailers in Abuja (FCT) and latest order date
SELECT r.RetailerID, r.BusinessName, MAX(o.OrderDate) AS LatestOrderDate
FROM dbo.Retailers r
LEFT JOIN dbo.SalesOrders o ON o.RetailerID = r.RetailerID
WHERE r.Channel='HoReCa' AND r.StateName IN ('Abuja FCT','FCT','Federal Capital Territory')
GROUP BY r.RetailerID, r.BusinessName
ORDER BY LatestOrderDate DESC;

-- B10 View: vw_RetailerOrderStats
SELECT TOP 20 * FROM dbo.vw_RetailerOrderStats ORDER BY DeliveredGMV DESC;

-- C) SalesOrders (10)
-- C1 CRUD Create: Insert a new order for existing retailer + agent (valid IDs)
DECLARE @r INT = (SELECT TOP 1 RetailerID FROM dbo.Retailers ORDER BY NEWID());
DECLARE @a INT = (SELECT TOP 1 AgentID FROM dbo.Agents ORDER BY NEWID());
INSERT INTO dbo.SalesOrders (OrderNumber, RetailerID, AgentID, OrderDate, FulfillmentType, StockPoint, Status, NetAmount, LastUpdatedAt)
VALUES (CONCAT('SO-MANUAL-', RIGHT(CONVERT(VARCHAR(36),NEWID()),6)), @r, @a, SYSDATETIME(), 'Delivery', 'OmniHub Agege Lagos - Deobell', 'Created', 0, SYSDATETIME());

-- C2 CRUD Update: Status Created → Confirmed and set LastUpdatedAt
UPDATE dbo.SalesOrders
SET Status='Confirmed', LastUpdatedAt=SYSDATETIME()
WHERE OrderID = (SELECT TOP 1 OrderID FROM dbo.SalesOrders WHERE Status='Created' ORDER BY OrderDate DESC);

-- C3 CRUD Delete: Delete orders with Status='Created' older than 90 days only if no payments
DELETE o
FROM dbo.SalesOrders o
WHERE o.Status='Created'
  AND o.OrderDate < DATEADD(DAY,-90, SYSDATETIME())
  AND NOT EXISTS (SELECT 1 FROM dbo.Payments p WHERE p.OrderID = o.OrderID);

-- C4 Sorting: Latest 30 orders with retailer + agent name
SELECT TOP 30
  o.OrderNumber, o.OrderDate, o.Status, o.NetAmount,
  r.BusinessName AS RetailerName,
  a.FullName AS AgentName
FROM dbo.SalesOrders o
JOIN dbo.Retailers r ON r.RetailerID = o.RetailerID
LEFT JOIN dbo.Agents a ON a.AgentID = o.AgentID
ORDER BY o.OrderDate DESC;

-- C5 Aggregate: Total orders per Status
SELECT Status, COUNT(*) AS TotalOrders
FROM dbo.SalesOrders
GROUP BY Status
ORDER BY TotalOrders DESC;

-- C6 Group By: Daily order count for last 30 days
SELECT CAST(OrderDate AS DATE) AS OrderDay, COUNT(*) AS Orders
FROM dbo.SalesOrders
WHERE OrderDate >= DATEADD(DAY,-30, SYSDATETIME())
GROUP BY CAST(OrderDate AS DATE)
ORDER BY OrderDay;

-- C7 Join: Delivered GMV by StockPoint
SELECT StockPoint, SUM(NetAmount) AS DeliveredGMV
FROM dbo.SalesOrders
WHERE Status='Delivered'
GROUP BY StockPoint
ORDER BY DeliveredGMV DESC;

-- C8 Join + Group By: Delivered count and avg NetAmount per agent
SELECT a.AgentID, a.FullName,
       SUM(CASE WHEN o.Status='Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
       AVG(CASE WHEN o.Status='Delivered' THEN o.NetAmount END) AS AvgDeliveredOrderValue
FROM dbo.Agents a
LEFT JOIN dbo.SalesOrders o ON o.AgentID = a.AgentID
GROUP BY a.AgentID, a.FullName
ORDER BY DeliveredCount DESC;

-- C9 Join + Condition: Cancelled orders with retailer, agent, reason, value
SELECT o.OrderNumber, o.NetAmount, o.CancelReason,
       r.BusinessName AS RetailerName,
       a.FullName AS AgentName
FROM dbo.SalesOrders o
JOIN dbo.Retailers r ON r.RetailerID = o.RetailerID
LEFT JOIN dbo.Agents a ON a.AgentID = o.AgentID
WHERE o.Status='Cancelled'
ORDER BY o.OrderDate DESC;

-- C10 Stored Procedure: usp_CreateOrderHeader
EXEC dbo.usp_CreateOrderHeader
  @RetailerID = (SELECT TOP 1 RetailerID FROM dbo.Retailers ORDER BY NEWID()),
  @AgentID    = (SELECT TOP 1 AgentID FROM dbo.Agents ORDER BY NEWID()),
  @FulfillmentType = 'Delivery',
  @StockPoint = 'OmniHub Ifako Ijaiye Lagos - Bickson';

-- D) SalesOrderLines (10)
-- D1 CRUD Create: Add a line item to an existing order
DECLARE @oid INT = (SELECT TOP 1 OrderID FROM dbo.SalesOrders ORDER BY NEWID());
INSERT INTO dbo.SalesOrderLines (OrderID, SKUCode, SKUName, Category, UOM, Qty, UnitPrice)
VALUES (@oid, 'SKU004', 'Rice 5kg', 'Grains', 'Carton', 2, 18500);

-- D2 CRUD Update: Update Qty for a given LineID (LineTotal is computed)
UPDATE dbo.SalesOrderLines
SET Qty = Qty + 1
WHERE LineID = (SELECT TOP 1 LineID FROM dbo.SalesOrderLines ORDER BY NEWID());

-- D3 CRUD Delete: Delete all lines for orders that were cancelled
DELETE l
FROM dbo.SalesOrderLines l
JOIN dbo.SalesOrders o ON o.OrderID = l.OrderID
WHERE o.Status='Cancelled';

-- D4 Sorting: Top 50 most expensive lines
SELECT TOP 50 *
FROM dbo.SalesOrderLines
ORDER BY LineTotal DESC;

-- D5 Aggregate: Total quantity sold by UOM
SELECT UOM, SUM(Qty) AS TotalQty
FROM dbo.SalesOrderLines
GROUP BY UOM
ORDER BY TotalQty DESC;

-- D6 Group By: Top 10 SKUs by revenue for delivered orders only
SELECT TOP 10 l.SKUName, SUM(l.LineTotal) AS Revenue
FROM dbo.SalesOrderLines l
JOIN dbo.SalesOrders o ON o.OrderID = l.OrderID
WHERE o.Status='Delivered'
GROUP BY l.SKUName
ORDER BY Revenue DESC;

-- D7 Join: Category revenue split per state (Orders → Retailers)
SELECT r.StateName, l.Category, SUM(l.LineTotal) AS Revenue
FROM dbo.SalesOrderLines l
JOIN dbo.SalesOrders o ON o.OrderID = l.OrderID
JOIN dbo.Retailers r ON r.RetailerID = o.RetailerID
GROUP BY r.StateName, l.Category
ORDER BY r.StateName, Revenue DESC;

-- D8 Left Join: Orders that have no lines
SELECT o.OrderNumber, o.Status
FROM dbo.SalesOrders o
LEFT JOIN dbo.SalesOrderLines l ON l.OrderID = o.OrderID
WHERE l.LineID IS NULL;

-- D9 Join + Filter: Orders where Rice 5kg sold in Carton and qty > 5
SELECT DISTINCT o.OrderNumber, l.Qty, l.UOM
FROM dbo.SalesOrders o
JOIN dbo.SalesOrderLines l ON l.OrderID = o.OrderID
WHERE l.SKUName='Rice 5kg' AND l.UOM='Carton' AND l.Qty > 5;

-- D10 View: vw_OrderBasket
SELECT TOP 30 * FROM dbo.vw_OrderBasket ORDER BY OrderNumber DESC;

-- E) Payments (10)
-- E1 CRUD Create: Insert a payment for an order with new Reference
DECLARE @oid2 INT = (SELECT TOP 1 OrderID FROM dbo.SalesOrders ORDER BY NEWID());
INSERT INTO dbo.Payments (OrderID, PaymentDate, Amount, Method, Reference, Status)
VALUES (@oid2, SYSDATETIME(), 50000, 'Transfer', CONCAT('PAY-MANUAL-', RIGHT(CONVERT(VARCHAR(36),NEWID()),6)), 'Pending');

-- E2 CRUD Update: Pending → Confirmed for a given Reference
UPDATE dbo.Payments
SET Status='Confirmed'
WHERE Reference = (SELECT TOP 1 Reference FROM dbo.Payments WHERE Status='Pending' ORDER BY PaymentDate DESC);

-- E3 CRUD Delete: Delete reversed payments older than 180 days
DELETE p
FROM dbo.Payments p
WHERE p.Status='Reversed'
  AND p.PaymentDate < DATEADD(DAY,-180, SYSDATETIME());

-- E4 Sorting: Latest 50 payments with order number + retailer name
SELECT TOP 50
  p.PaymentDate, p.Amount, p.Method, p.Status, p.Reference,
  o.OrderNumber,
  r.BusinessName AS RetailerName
FROM dbo.Payments p
JOIN dbo.SalesOrders o ON o.OrderID = p.OrderID
JOIN dbo.Retailers r ON r.RetailerID = o.RetailerID
ORDER BY p.PaymentDate DESC;

-- E5 Aggregate: Count payments by Method
SELECT Method, COUNT(*) AS PaymentCount
FROM dbo.Payments
GROUP BY Method
ORDER BY PaymentCount DESC;

-- E6 Group By: Daily payment totals for last 30 days
SELECT CAST(PaymentDate AS DATE) AS PayDay, SUM(Amount) AS TotalPaid
FROM dbo.Payments
WHERE PaymentDate >= DATEADD(DAY,-30, SYSDATETIME())
GROUP BY CAST(PaymentDate AS DATE)
ORDER BY PayDay;

-- E7 Join + Group By: Total amount paid per retailer + credit limit
SELECT r.RetailerID, r.BusinessName, r.CreditLimit,
       SUM(p.Amount) AS TotalPaid
FROM dbo.Retailers r
JOIN dbo.SalesOrders o ON o.RetailerID = r.RetailerID
JOIN dbo.Payments p ON p.OrderID = o.OrderID
WHERE p.Status='Confirmed'
GROUP BY r.RetailerID, r.BusinessName, r.CreditLimit
ORDER BY TotalPaid DESC;

-- E8 Join: For each order, total paid and outstanding (NetAmount - total confirmed paid)
SELECT
  o.OrderNumber,
  o.NetAmount,
  SUM(CASE WHEN p.Status='Confirmed' THEN p.Amount ELSE 0 END) AS TotalConfirmedPaid,
  (o.NetAmount - SUM(CASE WHEN p.Status='Confirmed' THEN p.Amount ELSE 0 END)) AS Outstanding
FROM dbo.SalesOrders o
LEFT JOIN dbo.Payments p ON p.OrderID = o.OrderID
GROUP BY o.OrderNumber, o.NetAmount
ORDER BY Outstanding DESC;

-- E9 Left Join: Delivered orders that have no confirmed payment
SELECT o.OrderNumber, o.NetAmount, o.OrderDate
FROM dbo.SalesOrders o
LEFT JOIN dbo.Payments p
  ON p.OrderID = o.OrderID AND p.Status='Confirmed'
WHERE o.Status='Delivered'
  AND p.PaymentID IS NULL
ORDER BY o.OrderDate DESC;

-- E10 Stored Procedure: usp_AddPayment
EXEC dbo.usp_AddPayment
  @OrderNumber = (SELECT TOP 1 OrderNumber FROM dbo.SalesOrders ORDER BY NEWID()),
  @Amount = 25000,
  @Method = 'Wallet',
  @Reference = CONCAT('PAY-SP-', RIGHT(CONVERT(VARCHAR(36),NEWID()),8));
GO
