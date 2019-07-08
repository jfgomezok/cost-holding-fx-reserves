

#################################################################################
#############   ACTUALIZACION DE LA LIBOR #######################################
#################################################################################

if(is.na(api.key)){stop('You should provide a API key')}



fred <- FredR(api.key)
US_tp <- fred$series.observations(series_id = "T5YFF", frequency="m")
US_tp$value <- as.numeric(US_tp$value)
US_tp$date <- as.Date(US_tp$date)
US_tp <- US_tp[,3:4]
# str(libor.fred)
US_tp <- na.omit(US_tp)

write.csv2(US_tp, file="raw_data/US_tp.csv", row.names = FALSE)
rm(fred, US_tp)
print("US term premium OK!")
