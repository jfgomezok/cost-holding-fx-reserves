

#################################################################################
#############   EMBI UPDATE SCRIPT ##############################################
#################################################################################

# library(wbstats)

# str(wb_cachelist, max.level = 1)
# new_cache <- wbcache()
# embi <- wbsearch(pattern = "embi")
# head(embi)


query.embi <- wb(indicator = "EMBIG",
                        startdate = "1990M01",
                        enddate = "2019M12",
                        POSIXct=TRUE)


# names(query.embi)

embi.wb <- query.embi %>%
  select(iso3c, value, iso2c, country, date_ct) %>%
  set_names(c("wbcode3", "spread", "wbcode2","country_name", "date"))

str(embi.wb)
# embi.wb$date <- as.Date(embi.wb$date)
# embi.wb$spread <- as.numeric(embi.wb$spread)
# embi.wb$wbcode2 <- as.factor(embi.wb$wbcode2)
# embi.wb$country_name <- as.factor(embi.wb$country_name)
# str(embi.wb)


write_csv2(x    = embi.wb,
           path = "raw_data/embi.wb.csv")


rm(embi.wb, query.embi)
print("embi ok!")
