con <- DBI::dbConnect(duckdb::duckdb())

DBI::dbExecute(con, 'INSTALL httpfs')
DBI::dbExecute(con, 'INSTALL aws')
DBI::dbDisconnect(con, shutdown=TRUE)
