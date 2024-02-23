import os

import duckdb

duckdb.sql("INSTALL httpfs")
duckdb.sql("INSTALL aws")
duckdb.sql("INSTALL postgres")
duckdb.sql("INSTALL spatial")
