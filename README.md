# 🛒 Olist E-commerce SQL Project

This project showcases a complete data cleaning, transformation, and aggregation pipeline using **PostgreSQL** and **Python** on the [Brazilian E-commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).  
It culminates in a unified, analysis-ready table for further BI reporting and dashboarding.

---

## 📦 Dataset Overview

This dataset includes:
- Orders, Customers, Products, Payments, Reviews, Order Items
- Sellers, Geolocation, and Category Translation

> Total Records: Over **1 million rows** across 9 tables.

---

## 🔧 Process Summary

| Task                                | Status       |
|-------------------------------------|--------------|
| Data Loading                        | ✅ Loaded via `\COPY` and Python script |
| Table Creation                      | ✅ Auto-generated from CSVs |
| Encoding Fix (UTF-8)                | ✅ Applied to `reviews.csv` |
| Cleaning and Standardization        | ✅ Done on all 9 tables |
| Complex View Creation               | ✅ `final_detailed_view` |
| Delivery & Delay Metrics            | ✅ Calculated in SQL |
| Volume Calculations (Products)      | ✅ Added as new column |
| Review Deduplication                | ✅ Retained latest per `order_id` |
| Payment Aggregation (per Order)     | ✅ With min/max installments |
| Product Categories (EN Translated)  | ✅ Included via `category_translation` |
| Final CSV Export                    | ✅ `Final Dataset - Brazilian E-commerce.csv` |

---

## 🏗 Project Structure

```bash
olist-ecommerce-sql-project/
│
├── data/                       # Cleaned or final datasets
│   └── Final Dataset - Brazilian E-commerce.csv
│
├── sql_scripts/               # View definitions and creation logic
│   ├── create_tables.sql
│   ├── base_orders.sql
│   └── final_detailed_view.sql
│
├── docs/                      # Process documentation
│   ├── logs_and_notes_tables.md
│   ├── Olist_Ecommerce_Articulated_Table.md
│   └── data_ingestion_and_table_creation(python & PSQL).md
│
└── README.md
