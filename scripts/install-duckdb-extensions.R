con <- DBI::dbConnect(duckdb::duckdb())

DBI::dbExecute(con, 'INSTALL httpfs from core_nightly')
DBI::dbExecute(con, 'INSTALL aws from core_nightly')
DBI::dbExecute(con, 'INSTALL postgres from core_nightly')
DBI::dbExecute(con, 'INSTALL spatial from core_nightly')
DBI::dbDisconnect(con, shutdown=TRUE)
