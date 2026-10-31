
from pathlib import Path
import pandas as pd
import pyodbc

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

SERVER = "localhost\\SQLEXPRESS"
DATABASE = "OlistDataWarehouse"

CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
)


def load_customers():
    # 1. Extract: Read the customer CSV
    file_path = RAW_DATA_DIR / "olist_order_items_dataset.csv"
    df = pd.read_csv(file_path, dtype=str)
    print(df.astype(str).apply(lambda col: col.str.len().max()))
    # 2. Transform: Convert pandas missing values to None
    df = df.astype(object).where(pd.notna(df), None)

    # 3. Load: Insert the records into SQL Server
    connection = pyodbc.connect(CONNECTION_STRING)
    cursor = connection.cursor()

    try:
        cursor.execute("TRUNCATE TABLE dbo.stg_order_items")

        insert_sql = """
            INSERT INTO dbo.stg_order_items (
                order_id,
                order_item_id,
                product_id,
                seller_id,
                shipping_limit_date,
                price,
                freight_value
            )
            VALUES (?, ?, ?, ?, ?,?,?)
        """

        rows = list(df.itertuples(index=False, name=None))

        cursor.fast_executemany = True
        cursor.executemany(insert_sql, rows)
        connection.commit()

        print(f"Successfully loaded {len(rows):,} order_items records.")

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    load_customers()
