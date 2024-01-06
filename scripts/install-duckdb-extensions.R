con <- DBI::dbConnect(duckdb::duckdb())

DBI::dbExecute(con, glue::glue('SET extension_directory=\"{Sys.getenv("HOME")}\"'))
DBI::dbExecute(con, 'INSTALL httpfs')
DBI::dbExecute(con, 'INSTALL aws')
