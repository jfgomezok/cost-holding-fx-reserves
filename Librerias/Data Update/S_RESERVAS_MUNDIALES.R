


#################################################################################
#############   ACTUALIZACION DE LAS RESERVAS MUNDIALES##########################
#################################################################################



# library(IMFData)


databaseID <- "IFS"
startdate <- "1980"
enddate <- ""
checkquery = FALSE
indicator <- c("RAXGFX_USD")
areas1 <- c("XR29","XR43", "JP", "CN", "TW", "XR21")
areas2 <- c("DZ","ID", "IR", "IQ", "KW","LY","NG","OM", "QA","SA","AE","VE")



queryfilter2 <- list(CL_FREA = "Q", CL_AREA_IFS = areas1, CL_INDICATOR_IFS = indicator)
query2 <- CompactDataMethod(databaseID, queryfilter2, startdate, enddate,
                            checkquery, tidy = TRUE)


queryfilter3 <- list(CL_FREA = "Q", CL_AREA_IFS = areas2, CL_INDICATOR_IFS = indicator)
query3 <- CompactDataMethod(databaseID, queryfilter3, startdate, enddate,
                            checkquery, tidy = TRUE)



base2 <- query2[c(1,4,2)]
colnames(base2) <- c("date","country.abb","value")
base2$value <- as.numeric(as.character(base2$value))
base2$date <- str_trim(base2$date)
# base2$date <- as.Date(as.yearmon(base2$date))
base2$country.abb <- as.factor(base2$country.abb)
# str(base2)

base3 <- spread(base2, country.abb, value)
colnames(base3) <-  c("date", "CN","JP","Taiwan","AdvEco","EmeEco")
# str(base3)



base5 <- query3[c(1,4,2)]
names(base5) <- c("date","country.abb","oil.exporters")
base5$oil.exporters <- as.numeric(as.character(base5$oil.exporters))
base5$date <- str_trim(base5$date)
# base2$date <- as.Date(as.yearmon(base2$date))
base5$country.abb <- as.factor(base5$country.abb)
# str(base5)

oil.exporters <- aggregate(oil.exporters ~ date , base5, sum)


base3<- merge(base3, oil.exporters, by="date")

base3$EM2 <- base3$EmeEco - base3$CN -base3$oil.exporters
base3$AE2 <- base3$AdvEco - base3$JP - base3$Taiwan

base3 <- base3[c(1,2,3,4,7,8,9)]



write.csv2(base3, file="raw_data/evolucion_reservas.csv",  row.names = FALSE)
rm(base2, base3, base5,oil.exporters,query2, query3, queryfilter2, queryfilter3, areas1, areas2, checkquery , databaseID, indicator, startdate, enddate)
print("reservas mundiales ok!")
