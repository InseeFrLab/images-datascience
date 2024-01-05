library(glue)
library(duckdb)

con <- dbConnect(duckdb())

dbExecute(con, glue('SET extension_directory=\"{Sys.getenv("HOME")}\"'))
dbExecute(con, 'INSTALL httpfs')
dbExecute(con, 'INSTALL aws')
