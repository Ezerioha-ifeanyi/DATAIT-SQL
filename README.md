# DATAIT-SQL
------------------------------------
The DATAIT SQL repository houses my SQL query solutions for my final project during the Cohort 5 period, where I solved 10 problems the FMCG industry faces with respect to their sales department, and also ensured that sales rose from 15% to about a 75% profit margin

----
The database used for this project was created manually using SQL scripts, which led to the creation of five(5) tables, namely: Agents, Retailers, SalesOrders, SalesOrderLines, and Payments. The database can be replicated using the scripts in the attached link: https://drive.google.com/file/d/1ShYszBSo2MBoQE6ymhxfht21Qo8F3eP7/view

---

## Database Schema Documentation

This database is designed to manage a retail sales network, tracking agents, retailers, sales orders, line items, and payments. Below is the detailed structure of each table.

### 1. `Agents` Table

Stores information about the sales representatives and city heads managing the retail network.

| Column Name | Data Type | Constraints | Description |
| --- | --- | --- | --- |
| **AgentID** | `INT` | `PK`, `IDENTITY(1,1)` | Unique auto-incrementing identifier for each agent. |
| **AgentCode** | `VARCHAR(20)` | `UNIQUE`, `NOT NULL` | A unique alphanumeric identifier/badge number assigned to the agent. |
| **FullName** | `VARCHAR(120)` | `NOT NULL` | The full legal name of the agent. |
| **Phone** | `VARCHAR(20)` | `NULL` | The agent's contact phone number. |
| **HomeState** | `VARCHAR(60)` | `NULL` | The state where the agent is based. |
| **HomeCity** | `VARCHAR(80)` | `NULL` | The city where the agent is based. |
| **Role** | `VARCHAR(40)` | `NOT NULL` | The agent's job title (e.g., *Sales Agent*, *City Head*). |
| **HireDate** | `DATE` | `NOT NULL` | The date the agent was officially hired or onboarded. |
| **Status** | `VARCHAR(20)` | `NOT NULL` | The agent's current employment status (e.g., *Active*, *Suspended*, *Exited*). |

### 2. `Retailers` Table

Contains the profiles of the various businesses, stores, and merchants purchasing goods.

| Column Name | Data Type | Constraints | Description |
| --- | --- | --- | --- |
| **RetailerID** | `INT` | `PK`, `IDENTITY(1,1)` | Unique auto-incrementing identifier for each retailer. |
| **BusinessName** | `VARCHAR(150)` | `NOT NULL` | The registered or trading name of the retailer's business. |
| **OwnerName** | `VARCHAR(120)` | `NULL` | The name of the business owner or primary contact. |
| **Phone** | `VARCHAR(20)` | `NULL` | The primary contact number for the retailer. |
| **Channel** | `VARCHAR(40)` | `NOT NULL` | The category of the business (e.g., *Retail*, *HoReCa*, *Supermarket*, *Pharmacy*). |
| **PaymentPreference** | `VARCHAR(30)` | `NOT NULL` | The retailer's preferred method of payment (e.g., *Cash*, *Transfer*, *Wallet*, *POS*). |
| **CreditLimit** | `DECIMAL(18,2)` | `NOT NULL`, Default: `0` | The maximum allowed credit amount for the retailer. |
| **StateName** | `VARCHAR(80)` | `NOT NULL` | The state where the business is located. |
| **CityName** | `VARCHAR(80)` | `NOT NULL` | The city where the business is located. |
| **AddressLine** | `VARCHAR(200)` | `NULL` | The physical street address of the business. |
| **CreatedAt** | `DATE` | `NOT NULL` | The date the retailer was registered in the system. |

### 3. `SalesOrders` Table

Records the header-level information for all purchases made by retailers.

| Column Name | Data Type | Constraints | Description |
| --- | --- | --- | --- |
| **OrderID** | `INT` | `PK`, `IDENTITY(1,1)` | Unique auto-incrementing identifier for the order. |
| **OrderNumber** | `VARCHAR(30)` | `UNIQUE`, `NOT NULL` | A human-readable, unique alphanumeric reference for the order. |
| **RetailerID** | `INT` | `FK`, `NOT NULL` | Links to the `Retailers` table, identifying who placed the order. |
| **AgentID** | `INT` | `FK`, `NULL` | Links to the `Agents` table. Nullable to support unassigned or direct orders. |
| **OrderDate** | `DATETIME2` | `NOT NULL` | The exact date and time the order was placed. |
| **FulfillmentType** | `VARCHAR(20)` | `NOT NULL` | How the order gets to the customer (e.g., *Delivery*, *SelfPickup*). |
| **StockPoint** | `VARCHAR(120)` | `NOT NULL` | The warehouse or hub fulfilling the order (e.g., *OmniHub Agege Lagos*). |
| **Status** | `VARCHAR(20)` | `NOT NULL` | The current state of the order (e.g., *Created*, *Packed*, *Dispatched*, *Delivered*). |
| **CancelReason** | `VARCHAR(200)` | `NULL` | The reason for cancellation, if the order status is *Cancelled*. |
| **NetAmount** | `DECIMAL(18,2)` | `NOT NULL`, Default: `0` | The total final cost of the order after any modifications. |
| **LastUpdatedAt** | `DATETIME2` | `NULL` | The timestamp of the most recent change to the order's status or details. |

### 4. `SalesOrderLines` Table

Stores the individual line items (products) associated with each sales order.

| Column Name | Data Type | Constraints | Description |
| --- | --- | --- | --- |
| **LineID** | `INT` | `PK`, `IDENTITY(1,1)` | Unique auto-incrementing identifier for the line item. |
| **OrderID** | `INT` | `FK`, `NOT NULL` | Links the item to its parent order in the `SalesOrders` table. |
| **SKUCode** | `VARCHAR(30)` | `NOT NULL` | The unique Stock Keeping Unit identifier for the product. |
| **SKUName** | `VARCHAR(200)` | `NOT NULL` | The descriptive name of the product. |
| **Category** | `VARCHAR(80)` | `NOT NULL` | The product category (e.g., *Beverages*, *Snacks*, *Hygiene*). |
| **UOM** | `VARCHAR(20)` | `NOT NULL` | The Unit of Measure for the product (e.g., *Carton*, *Pack*, *Piece*). |
| **Qty** | `INT` | `NOT NULL` | The quantity of the product ordered. |
| **UnitPrice** | `DECIMAL(18,2)` | `NOT NULL` | The price per single unit of the product. |
| **LineTotal** | `DECIMAL(18,2)` | `PERSISTED` | **Computed Column**: Automatically calculates the total cost (`Qty` × `UnitPrice`). |

### 5. `Payments` Table

Tracks financial transactions and payment statuses tied to specific sales orders.

| Column Name | Data Type | Constraints | Description |
| --- | --- | --- | --- |
| **PaymentID** | `INT` | `PK`, `IDENTITY(1,1)` | Unique auto-incrementing identifier for the payment record. |
| **OrderID** | `INT` | `FK`, `NOT NULL` | Links the payment to the corresponding order in `SalesOrders`. |
| **PaymentDate** | `DATETIME2` | `NOT NULL` | The exact date and time the payment was made. |
| **Amount** | `DECIMAL(18,2)` | `NOT NULL` | The total amount paid in this specific transaction. |
| **Method** | `VARCHAR(20)` | `NOT NULL` | The payment medium utilized (e.g., *Cash*, *Transfer*, *Wallet*, *POS*). |
| **Reference** | `VARCHAR(60)` | `UNIQUE`, `NOT NULL` | A unique transaction ID or receipt number from the payment provider. |
| **Status** | `VARCHAR(20)` | `NOT NULL` | The current state of the payment (e.g., *Pending*, *Confirmed*, *Reversed*). |
| **CreatedAt** | `DATETIME2` | `NOT NULL` | System timestamp of when the payment record was created. |

### Indexes

To optimize query performance, the following non-clustered indexes have been implemented:

* `IX_SalesOrders_OrderDate`: Optimizes time-series queries and date filtering on orders.
* `IX_SalesOrders_Status`: Speeds up filtering orders by their current fulfillment state.
* `IX_OrderLines_OrderID`: Enhances JOIN performance when retrieving line items for a specific order.
* `IX_Payments_OrderID`: Enhances JOIN performance when pulling payment histories for specific orders.

---




