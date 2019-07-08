

#################################################################################
#############   ACTUALIZACION DEL RIESGO EMERGING MARKET#########################
#################################################################################


# library(FredR)

if(is.na(api.key)){stop('You should provide a API key')}



fred <- FredR(api.key)
bofahy <- fred$series.observations(series_id = "BAMLH0A0HYM2", frequency = "m")[-1,]
bofahy$date <- as.Date(bofahy$date)
bofahy$value <- as.numeric(bofahy$value)*100

bofahy <- bofahy[,3:4]

colnames(bofahy) <- c("date", "hy.fred" )

write.csv2(bofahy, file="raw_data/risk.aversion.csv", row.names = FALSE)
rm(bofahy,  fred)
print("risk aversion ok!")
