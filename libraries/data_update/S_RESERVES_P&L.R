
#################################################################################
#############   P&L RESERVES UPDATE SCRIPT ######################################
#################################################################################


# library(IMFData)


# IFS.available.codes <- DataStructureMethod("IFS")
# All_Areas <- IFS.available.codes[[2]]
# All_Indicators <- IFS.available.codes[[3]]

databaseID <- "IFS"
startdate <- "1980"
enddate <- ""
checkquery = FALSE
indicator <- c("ENDE_XDC_USD_RATE","RAXGFX_USD")
areas <- c("BR", "RU","TR","KR", "MX", "AR")

queryfilter <- list(CL_FREA = "M", CL_AREA_IFS = areas, CL_INDICATOR_IFS = indicator)

query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate,
                           checkquery, tidy = TRUE)


reserves <- query[c(1,4,5,2)]
colnames(reserves) <- c("date","country.abb","indicator","value")
reserves$value <- as.numeric(as.character(reserves$value))
reserves$date <- str_trim(reserves$date)
reserves$date <- as.Date(as.yearmon(reserves$date))


reserves <- spread(reserves, indicator, value)
colnames(reserves) <-  c("date", "country.abb","NER","reserves")


orden <- order(reserves$country.abb)
reserves <- reserves[orden,]


# str(reserves)

write_csv2(x    = reserves,
           path = "raw_data/Reserves_NER.csv")

rm(reserves, orden,  queryfilter,databaseID, startdate, enddate,checkquery, query , indicator, areas )
print("reserves P&L OK!")
