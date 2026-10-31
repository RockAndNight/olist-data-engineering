
from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def validate_customers():
    file_path = RAW_DATA_DIR / "olist_orders_dataset.csv"

    df = pd.read_csv(file_path)

    print("Customer Data Validation")
    print("-" * 40)

    # Check 1: Total number of rows
    print(f"Total rows: {len(df):,}")

    # Check 2: Missing values in important columns
    required_columns = [
        "order_id",
        "customer_id",
        "order_status",
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ]

    for column in required_columns:
        missing_count = df[column].isnull().sum()
        print(f"{column}: {missing_count} missing values")

    # Check 3: Duplicate customer IDs
    duplicate_ids = df["order_id"].duplicated().sum()
    print(f"Duplicate customer IDs: {duplicate_ids}")


if __name__ == "__main__":
    validate_customers()
