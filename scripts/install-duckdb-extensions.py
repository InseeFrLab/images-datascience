import os

import duckdb

duckdb.sql(f"SET extension_directory=\"{os.getenv('HOME')}\"")
duckdb.sql("INSTALL httpfs")
duckdb.sql("INSTALL aws")
