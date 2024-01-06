con <- DBI::dbConnect(duckdb::duckdb())
DBI::dbExecute(con, 'LOAD httpfs')
DBI::dbExecute(con, glue::glue('SET s3_endpoint=\"{Sys.getenv("AWS_S3_ENDPOINT")}\"'))
