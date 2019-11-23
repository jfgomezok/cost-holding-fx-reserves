

#################################################################################
#############   US10Y DATA UPDATE SCRIPT ########################################
#################################################################################

# library(FredR)

if(is.na(api.key)){stop('You should provide a API key')}


fred <- FredR(api.key)
US10y.fred <- fred$series.observations(series_id = "DGS10", frequency="m")

str(US10y.fred)

US10y.fred <- US10y.fred %>%
              mutate(value = parse_number(value),
                     date = parse_date(date)) %>%
              select(date, value)

# ()$value <- as.numeric(US10y.fred$value)
# US10y.fred$date <- as.Date(US10y.fred$date)
# str(US10y.fred)

write_csv2(x = US10y.fred, path = "raw_data/us10y.csv")
rm(fred, US10y.fred  )
print("us10y ok!")