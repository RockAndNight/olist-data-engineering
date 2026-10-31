
from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def inspect_csv_files():
    csv_files = sorted(RAW_DATA_DIR.glob("*.csv"))

    if not csv_files:
        print(f"No CSV files found in: {RAW_DATA_DIR}")
        return

    print(f"Found {len(csv_files)} CSV files\n")

    for file_path in csv_files:
        try:
            df = pd.read_csv(file_path)

            print(f"\n{'=' * 60}")
            print(f"File: {file_path.name}")
            print(f"Total rows: {len(df):,}")
            print(f"Total columns: {len(df.columns)}")
            print(f"Duplicate rows: {df.duplicated().sum():,}")
            print("\nMissing values:")
            print(df.isnull().sum().to_string())

        except Exception as error:
            print(f"Error reading {file_path.name}: {error}")


if __name__ == "__main__":
    inspect_csv_files()
