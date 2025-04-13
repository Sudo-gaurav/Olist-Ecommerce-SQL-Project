# Data Ingestion & Table Creation – Olist E-commerce

This document outlines the step-by-step process for programmatically creating PostgreSQL tables from CSV files, fixing encoding issues, and verifying data ingestion. This approach ensures scalability, automation, and UTF-8 compliance across all datasets.

---

## 🐍 Python Script: Generate `CREATE TABLE` Statements

```python
import pandas as pd
import os

# Folder where CSVs are stored
csv_folder = r"C:\Users\gaura\Downloads\Data Analyst (Elevate Labs)\Task 3\Brazilian E-commerce Public Dataset By Olist"
output_sql = os.path.join(csv_folder, "create_tables.sql")

# Guess column types based on pandas dtype
def guess_pg_type(dtype):
    if pd.api.types.is_integer_dtype(dtype):
        return "INTEGER"
    elif pd.api.types.is_float_dtype(dtype):
        return "FLOAT"
    elif pd.api.types.is_datetime64_any_dtype(dtype):
        return "TIMESTAMP"
    else:
        return "TEXT"

with open(output_sql, "w", encoding="utf-8") as f:
    for file in os.listdir(csv_folder):
        if file.endswith(".csv"):
            table_name = file.replace(".csv", "").lower()
            df = pd.read_csv(os.path.join(csv_folder, file), nrows=200)

            f.write(f"-- Table: {table_name}\n")
            f.write(f"DROP TABLE IF EXISTS {table_name};\n")
            f.write(f"CREATE TABLE {table_name} (\n")

            cols = []
            for col in df.columns:
                pg_type = guess_pg_type(df[col])
                cols.append(f'  "{col}" {pg_type}')
            f.write(",\n".join(cols))
            f.write("\n);\n\n")
```

This script auto-generates a `create_tables.sql` file based on the column types inferred from the first 200 rows of each CSV.

---

## 💾 Running SQL in PostgreSQL

### Step 1: Load Tables

```bash
psql -U postgres -d ecommerce_olist -h localhost -p 5432
```

Then within the `psql` CLI:

```sql
-- Run generated SQL to create tables
\i 'C:/Users/gaura/.../create_tables.sql'
```

### Step 2: Load Data from CSV

```sql
\COPY orders FROM 'C:/.../orders.csv' DELIMITER ',' CSV HEADER;
\COPY customers FROM 'C:/.../customers.csv' DELIMITER ',' CSV HEADER;
\COPY products FROM 'C:/.../products.csv' DELIMITER ',' CSV HEADER;
\COPY order_items FROM 'C:/.../order_items.csv' DELIMITER ',' CSV HEADER;
\COPY payments FROM 'C:/.../payments.csv' DELIMITER ',' CSV HEADER;
\COPY reviews FROM 'C:/.../reviews.csv' DELIMITER ',' CSV HEADER; -- May throw UTF-8 error
\COPY geolocation FROM 'C:/.../geolocation.csv' DELIMITER ',' CSV HEADER;
\COPY sellers FROM 'C:/.../sellers.csv' DELIMITER ',' CSV HEADER;
\COPY category_translation FROM 'C:/.../category_translation.csv' DELIMITER ',' CSV HEADER;
```

---

## ❗ Fixing Encoding Issues (for `reviews.csv`)

You may get this error:
```
ERROR: character with byte sequence 0x8f in encoding "WIN1252" has no equivalent in encoding "UTF8"
```

### ✅ Fix: Re-encode to UTF-8 using Python
```python
import codecs

source = r'C:\...\reviews.csv'
target = r'C:\...\reviews_utf8.csv'

with codecs.open(source, 'r', 'cp1252') as sf:
    with codecs.open(target, 'w', 'utf-8') as tf:
        tf.write(sf.read())
```

Then reload:
```sql
\COPY reviews FROM 'C:/.../reviews_utf8.csv' DELIMITER ',' CSV HEADER;
```

---

## 🔍 Validation (Optional but Recommended)

### View All Tables
```sql
\dt
```

### Preview Table Content
```sql
SELECT * FROM customers LIMIT 5;
```

### View Table Schema
```sql
\d+ payments
```

---

## ✅ Summary

| Task                         | Status        |
|------------------------------|---------------|
| Generated SQL from CSV       | ✅ Done via Python |
| Created PostgreSQL Tables    | ✅ Done via psql `\i` |
| Loaded CSV data              | ✅ Using `\COPY` |
| Fixed encoding issues        | ✅ For `reviews.csv` |
| Verified schemas and counts  | ✅ Spot checked in `psql` |

