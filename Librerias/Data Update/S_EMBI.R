

#################################################################################
#############   ACTUALIZACION DEL RIESGO PAIS ###################################
#################################################################################

# library(wbstats)

# str(wb_cachelist, max.level = 1)
# new_cache <- wbcache()
# embi <- wbsearch(pattern = "embi")
# head(embi)


query.embi <- wb(indicator = "EMBIG",
                        startdate = "1990M01",
                        enddate = "2018M12",
                        POSIXct=TRUE)

embi.wb <- query.embi[c(1,3,6,7,8)]
colnames(embi.wb) <- c("wbcode3", "spread", "wbcode2","country_name", "date")
embi.wb$date <- as.Date(embi.wb$date)
embi.wb$spread <- as.numeric(embi.wb$spread)
embi.wb$wbcode2 <- as.factor(embi.wb$wbcode2)
embi.wb$country_name <- as.factor(embi.wb$country_name)
# str(embi.wb)


write.csv2(embi.wb, file="raw_data/embi.wb.csv", row.names = FALSE)


rm(embi.wb, query.embi)
print("embi ok!")
