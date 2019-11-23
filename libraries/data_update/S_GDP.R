

#################################################################################
#############  GDP UPDATE SCRIPT ################################################
#################################################################################


# library(wbstats)
# library(ggplot2)



# Source: https://data.worldbank.org/indicator/NY.GDP.MKTP.CD?locations=AR

query.gdp <- wb(indicator = "NY.GDP.MKTP.CD",
             startdate = "1970",
             enddate = "2018",
             POSIXct=TRUE)

# str(query.gdp)

gdp <- query.gdp %>%
       mutate(value = value / 1000000000) %>%
       select(iso3c, value, iso2c, country, date_ct) %>%
       set_names(c("wbcode3", "gdp", "wbcode2","country_name", "date"))

# str(gdp)


# Sandbox:
# gdp %>% filter(wbcode3 == 'BRA') %>%
# ggplot(aes(x=date, y=gdp))+
#   geom_line()


write_csv2(x    = gdp,
           path = "raw_data/GDP_data.csv")


rm(query.gdp, gdp)
print("gdp ok!")

