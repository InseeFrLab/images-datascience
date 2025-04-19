con <- DBI::dbConnect(duckdb::duckdb())

DBI::dbExecute(con, 'INSTALL httpfs')
DBI::dbExecute(con, 'INSTALL aws')
DBI::dbExecute(con, 'INSTALL postgres')
DBI::dbExecute(con, 'INSTALL spatial')
DBI::dbDisconnect(con, shutdown=TRUE)
