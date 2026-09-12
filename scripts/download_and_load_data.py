import os
import sys
import time
import urllib.request
import duckdb

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
DB_PATH = os.path.join(os.path.dirname(__file__), "..", "dev.duckdb")

FILES = {
    "orders.csv": "https://huggingface.co/datasets/attik/Instacart-Market-Basket-Analysis/resolve/main/orders.csv",
    "order_products__prior.csv": "https://huggingface.co/datasets/attik/Instacart-Market-Basket-Analysis/resolve/main/order_products__prior.csv"
}

def download_file(url, target_path):
    print(f"Checking {target_path}...")
    if os.path.exists(target_path) and os.path.getsize(target_path) > 1024 * 1024:
        print(f"File {target_path} already exists ({os.path.getsize(target_path) / (1024*1024):.1f} MB). Skipping download.")
        return
    print(f"Downloading from {url} to {target_path}...")
    start_time = time.time()
    
    def reporthook(block_num, block_size, total_size):
        downloaded = block_num * block_size
        if total_size > 0:
            percent = downloaded / total_size * 100
            mb_done = downloaded / (1024 * 1024)
            mb_total = total_size / (1024 * 1024)
            elapsed = time.time() - start_time
            speed = mb_done / elapsed if elapsed > 0 else 0
            if block_num % 1000 == 0:
                print(f"\rProgress: {percent:.1f}% ({mb_done:.1f}/{mb_total:.1f} MB) @ {speed:.2f} MB/s", end="", flush=True)

    urllib.request.urlretrieve(url, target_path, reporthook=reporthook)
    print(f"\nDownloaded {target_path} in {time.time() - start_time:.1f}s")

os.makedirs(DATA_DIR, exist_ok=True)

for fname, url in FILES.items():
    dest = os.path.join(DATA_DIR, fname)
    download_file(url, dest)

print(f"\nConnecting to DuckDB database at {DB_PATH}...")
con = duckdb.connect(DB_PATH)

orders_path = os.path.abspath(os.path.join(DATA_DIR, "orders.csv"))
con.execute("""
    CREATE TABLE IF NOT EXISTS main.orders AS
    SELECT * FROM read_csv_auto(?)
""", [orders_path])
orders_count = con.execute("SELECT COUNT(*) FROM main.orders").fetchone()[0]
print(f"Loaded {orders_count:,} rows into main.orders")

order_prods_path = os.path.abspath(os.path.join(DATA_DIR, "order_products__prior.csv"))
con.execute("""
    CREATE TABLE IF NOT EXISTS main.order_products__prior AS
    SELECT * FROM read_csv_auto(?)
""", [order_prods_path])
prods_count = con.execute("SELECT COUNT(*) FROM main.order_products__prior").fetchone()[0]
print(f"Loaded {prods_count:,} rows into main.order_products__prior")

con.close()
print("\nAll data loaded successfully!")
