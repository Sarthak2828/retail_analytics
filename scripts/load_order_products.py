import duckdb
import os

# Build the path relative to this script's location, then go up one level to the project root
db_path = os.path.join(os.path.dirname(__file__), "..", "dev.duckdb")

# Update this path for input CSV file
csv_path = r"C:\Users\mwood\Data\instacart\order_products__prior.csv"

# Connect to the existing DuckDB file that dbt uses, so the table will be visible to dbt models
con = duckdb.connect(db_path)

# Create table directly from CSV using DuckDB's native CSV reader
# IF NOT EXISTS so we can safely re-run this without duplicating data
con.execute("""
    CREATE TABLE IF NOT EXISTS main.order_products__prior AS
    SELECT * FROM read_csv_auto(?)
""", [csv_path])

# Quick sanity check. Confirm the row count looks right
count = con.execute("SELECT COUNT(*) FROM main.order_products__prior").fetchone()[0]
print(f"Loaded {count:,} rows into order_products__prior")

# Always close the connection. DuckDB only allows one writer at a time
# If you leave this open and then run dbt, you'll get a lock error
con.close()