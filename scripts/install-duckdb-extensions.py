import os

import duckdb

duckdb.sql("INSTALL httpfs")
duckdb.sql("INSTALL aws")
