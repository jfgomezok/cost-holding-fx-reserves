

#################################################################################
#############   ACTUALIZACION DEL LA US10Y ###################################
#################################################################################

# library(FredR)

if(is.na(api.key)){stop('You should provide a API key')}


fred <- FredR(api.key)
US10y.fred <- fred$series.observations(series_id = "DGS10", frequency="m")
US10y.fred$value <- as.numeric(US10y.fred$value)
US10y.fred$date <- as.Date(US10y.fred$date)
# str(US10y.fred)

write.csv2(US10y.fred, file="raw_data/us10y.csv", row.names = FALSE)
rm(fred, US10y.fred  )
print("us10y ok!")
