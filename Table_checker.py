import pandas as pd
import pyodbc

# Connection parameters
server = r'SQLODSDEV\ODS'
database = 'TempDataLake'
conn_str = f'DRIVER={{ODBC DRIVER 13 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

# CSV file path
csv_file = 'synthetic_data.csv'

# Table name in MSSQL
table_name = 'SyntheticData'

# Read CSV into pandas DataFrame
df = pd.read_csv(csv_file)

# Connect to MSSQL server
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Define the SQL insert statement
sql_insert = f'''
    INSERT INTO [MOCK_DATA].[SYN_CUSTOMER] (UID, GUID, FIRST_NAME, LAST_NAME, EMAIL, BIRTH_DATE, SIN, SALT, HASHKEY)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
'''

# Execute batch insert
batch_size = 1000  # Adjust batch size as needed
for i in range(0, len(df), batch_size):
    batch = df.iloc[i:i+batch_size]
    params = [tuple(row) for row in batch.values]  # Convert DataFrame rows to tuples
    cursor.executemany(sql_insert, params)

# Commit changes and close connection
conn.commit()
conn.close()

print("Data inserted into MSSQL table successfully.")
