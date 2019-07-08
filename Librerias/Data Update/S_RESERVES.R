

#################################################################################
#############   ACTUALIZACION DE LAS RESERVAS ###################################
#################################################################################


# library(IMFData)


IFS.available.codes <- DataStructureMethod("IFS")
All_Areas <- IFS.available.codes[[2]]
All_Indicators <- IFS.available.codes[[3]]

databaseID <- "IFS"
startdate <- "1980"
start.date <- as.Date("2004-11-01")
end.date <- as.Date("2018-09-01")
enddate <- "2018"
checkquery = FALSE
indicator <- c("RAFA_MV_USD")
areas <- ""

queryfilter <- list(CL_FREA = "M", CL_AREA_IFS = areas, CL_INDICATOR_IFS = indicator)

reserves.ifs <- CompactDataMethod(databaseID, queryfilter, startdate, enddate,
                           checkquery,verbose = FALSE, tidy = TRUE)

reserves.ifs <- reserves.ifs[c(1,4,2)]

colnames(reserves.ifs) <- c("date","wbcode2","reserves")
reserves.ifs$reserves <- as.numeric(as.character(reserves.ifs$reserves))
reserves.ifs$date <- paste0(reserves.ifs$date, "-01"   )
reserves.ifs$date <- as.Date(reserves.ifs$date)
reserves.ifs$wbcode2 <- as.factor(reserves.ifs$wbcode2)

countries.imf <- read.csv2("Inputs/imfcountriesmetadata.csv")


reserves.ifs <- merge (reserves.ifs, countries.imf[,c(3,4)], by.x = "wbcode2", by.y = "Country.ISO.2.Code")
colnames(reserves.ifs)[4] <- "wbcode3" 
reserves.ifs <- reserves.ifs[,c(4,2,3)]
# str(reserves.ifs)

write.csv2(reserves.ifs, file="raw_data/reserves.ifs.csv", row.names = FALSE)
rm(countries.imf, reserves.ifs, queryfilter,databaseID, startdate, start.date, end.date, enddate,checkquery, indicator, areas , All_Areas, All_Indicators, IFS.available.codes)
print("reserves ok!")
