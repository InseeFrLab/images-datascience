import os

import duckdb

duckdb.sql("LOAD httpfs")
duckdb.sql(f"SET s3_endpoint=\"{os.getenv('AWS_S3_ENDPOINT')}\"")
