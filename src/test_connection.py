
import pyodbc

SERVER = "localhost\\SQLEXPRESS"

DATABASE = "OlistDataWarehouse"

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
)

try:
    connection = pyodbc.connect(connection_string, timeout=10)

    print("Successfully connected to SQL Server!")

    cursor = connection.cursor()
    cursor.execute("SELECT DB_NAME()")

    print("Connected database:", cursor.fetchone()[0])

    connection.close()

except pyodbc.Error as error:
    print("Database connection failed:")
    print(error)
