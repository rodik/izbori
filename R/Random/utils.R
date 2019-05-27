# utils
library(openxlsx)

spremiXLSX <- function(data, fileName)
{
    if (is.data.frame(data)) {
        df <- data
        wb <- createWorkbook()
        addWorksheet(wb = wb, sheetName = "Sheet 1", gridLines = FALSE)
        writeDataTable(wb = wb, sheet = 1, x = df)
        saveWorkbook(wb, fileName, overwrite = TRUE)
    }
    else if (is.list(data)) {
        wb <- createWorkbook()
        for(i in 1:length(data)){
            df <- data[i]
            df_name <- names(df)
            addWorksheet(wb = wb, sheetName = df_name, gridLines = FALSE)
            writeDataTable(wb = wb, sheet = df_name, x = as_data_frame(df[[1]]))
        }
        saveWorkbook(wb, fileName, overwrite = TRUE)
    }
}

spremiCSV <- function(df, fileName, encoding="UTF-8", sep = ';', na ='', row.names = FALSE)
{
    con<-file(fileName, encoding=encoding)
    # KORISTITI WRITE TABLE
    write.table(df, file=con, na=na, sep = sep, row.names = row.names, qmethod = "double" )
    # close.connection(con)
}