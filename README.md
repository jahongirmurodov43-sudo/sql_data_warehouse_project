# Data Warehouse and Analytics Project

Welcome to my **Data Warehouse and Analytics Project** repository!

This project demonstrates an end-to-end data warehousing and analytics solution built with **SQL Server** — from ingesting raw source data, through cleansing and modeling, all the way to delivering business-ready analytical insights. It is designed as a portfolio piece that reflects industry best practices in data engineering and analytics.

---

## Project Overview

The project consolidates sales data from two source systems (**ERP** and **CRM**) into a single, analytics-ready data model. It follows the **Medallion Architecture** pattern (Bronze → Silver → Gold), which is widely used in modern data platforms.

**What this project delivers:**

- A clean, layered data warehouse implemented in SQL Server
- ETL processes that move data through Bronze, Silver, and Gold layers
- A star schema optimized for analytical queries
- SQL-based reports answering real business questions about customers, products, and sales

---

## Data Architecture

The warehouse is organized into three layers, each with a clear responsibility:

```
       ┌─────────────────┐         ┌─────────────────┐
       │   CRM (CSV)     │         │   ERP (CSV)     │
       └────────┬────────┘         └────────┬────────┘
                │                           │
                └─────────────┬─────────────┘
                              ▼
                ┌──────────────────────────┐
                │   BRONZE LAYER           │
                │   Raw data, as-is        │
                │   (truncate & load)      │
                └────────────┬─────────────┘
                             ▼
                ┌──────────────────────────┐
                │   SILVER LAYER           │
                │   Cleansed, standardized │
                │   data quality applied   │
                └────────────┬─────────────┘
                             ▼
                ┌──────────────────────────┐
                │   GOLD LAYER             │
                │   Star schema            │
                │   Business-ready views   │
                └────────────┬─────────────┘
                             ▼
                ┌──────────────────────────┐
                │   Analytics & Reports    │
                └──────────────────────────┘
```

| Layer      | Purpose                                                                 | Object Type            |
| ---------- | ----------------------------------------------------------------------- | ---------------------- |
| **Bronze** | Raw ingestion from CSV files, no transformations                        | Tables (full reload)   |
| **Silver** | Data cleansing, standardization, type casting, derived fields           | Tables                 |
| **Gold**   | Business-friendly star schema (fact + dimensions) for reporting         | Views                  |

---

## Data Model (Gold Layer)

The Gold layer exposes a **star schema** designed for fast analytical queries:

- **`fact_sales`** — sales transactions (one row per order line)
- **`dim_customers`** — customer attributes from CRM enriched with ERP demographics and location
- **`dim_products`** — product attributes from CRM enriched with ERP product categories

Each dimension uses a surrogate key generated in the Gold layer, while the fact table joins back to dimensions through these keys.

---

## Tech Stack

- **Database:** Microsoft SQL Server (Express edition is sufficient)
- **IDE:** SQL Server Management Studio (SSMS)
- **Language:** T-SQL
- **Source Format:** CSV files (ERP and CRM exports)
- **Version Control:** Git / GitHub

---

## Repository Structure

```
sql_data_warehouse_project/
│
├── datasets/                  # Source CSV files (ERP + CRM)
│
├── docs/                      # Documentation, diagrams, data catalog
│
├── scripts/                   # All SQL scripts, organized by layer
│   ├── bronze/                # DDL + load procedures for raw data
│   ├── silver/                # DDL + cleansing transformations
│   └── gold/                  # Star schema views
│
├── tests/                     # Data quality checks for Silver and Gold
│
├── LICENSE                    # MIT License
└── README.md                  # You are here
```

---

## Project Requirements

### 1. Building the Data Warehouse (Data Engineering)

**Objective:** Build a modern data warehouse in SQL Server that consolidates sales data and supports analytical reporting.

**Specifications:**

- **Data Sources:** Import data from two sources (ERP and CRM), both provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues before analysis (nulls, duplicates, type mismatches, inconsistent codes).
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Use the latest dataset only — historization (SCD Type 2) is out of scope.
- **Documentation:** Provide clear documentation of the data model so business stakeholders and analysts can use it.

### 2. BI: Analytics & Reporting (Data Analytics)

**Objective:** Develop SQL-based analytics that deliver insights into:

- **Customer Behavior** — segmentation, lifetime value, recency
- **Product Performance** — best/worst sellers, category trends
- **Sales Trends** — time-based patterns, growth, seasonality

These insights give stakeholders the metrics they need for informed, strategic decision-making.

---

## How to Run This Project

### Prerequisites

- SQL Server 2019 or newer (any edition, including Express)
- SQL Server Management Studio (SSMS)
- The CSV source files from the `datasets/` folder

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/jahongirmurodov43-sudo/sql_data_warehouse_project.git
   ```

2. **Create the database and schemas**
   Run the initialization script in `scripts/` to create the `DataWarehouse` database and the `bronze`, `silver`, and `gold` schemas.

3. **Update the file paths**
   Inside the Bronze load procedures, update the `BULK INSERT` paths so they point to the location of the CSV files on your machine.

4. **Run the layers in order**
   - Execute Bronze DDL → run the Bronze load procedure
   - Execute Silver DDL → run the Silver load procedure
   - Execute Gold views

5. **Validate with the tests folder**
   Run the scripts in `tests/` to confirm referential integrity and data quality.

6. **Explore the analytics**
   Query the Gold views to answer business questions about sales, customers, and products.

---

## Key Learnings

Through this project I practiced:

- Designing a layered data warehouse using the Medallion Architecture
- Writing T-SQL stored procedures for repeatable ETL loads
- Performing data cleansing and standardization across multiple source systems
- Modeling a star schema with surrogate keys
- Writing data quality tests as part of the pipeline
- Producing analytical SQL on top of a dimensional model

---

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share it with proper attribution.

---

## About Me

Hi! I'm **Jahongir Murodov**, a senior-year student studying Digital Economy, currently taking a Data Analytics course at **MAAB Academy**.

I built this project by following the excellent free YouTube tutorial from **Baraa Khatib Salkini** ([Data with Baraa](https://www.youtube.com/@DataWithBaraa)). His curriculum and datasets were the foundation for the work in this repository — full credit to him for the teaching materials. This repo is my hands-on implementation as I learn data engineering.

Feel free to connect with me or open an issue if you have questions!
