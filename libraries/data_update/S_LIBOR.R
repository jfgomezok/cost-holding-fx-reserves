

#################################################################################
#############   ACTUALIZACION DE LA LIBOR #######################################
#################################################################################


if(is.na(api.key)){stop('You should provide a API key')}


fred <- FredR(api.key)
libor.fred <- fred$series.observations(series_id = "GBP3MTD156N", frequency="m")
libor.fred$value <- as.numeric(libor.fred$value)
libor.fred$date <- as.Date(libor.fred$date)
libor.fred <- libor.fred[,3:4]
# str(libor.fred)

colnames(libor.fred) <- c("date", "libor.TNA")
libor.fred$month <- format(as.Date(libor.fred$date, "%Y-%m-%d"), "%Y-%m-01")
libor.fred.monthly <- aggregate( libor.TNA ~ month, libor.fred, mean)
colnames(libor.fred.monthly) <- c("date", "libor")
libor.fred.monthly$date <- as.Date(as.yearmon(libor.fred.monthly$date))
# str(libor.fred.monthly)


write.csv2(libor.fred.monthly, file="raw_data/libor.csv", row.names = FALSE)
rm(fred, libor.fred, libor.fred.monthly)
print("libor OK!")
