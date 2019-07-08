

#################################################################################
#############   ACTUALIZACION DEl GDP 3333333 ###################################
#################################################################################


# library(wbstats)
# library(ggplot2)


# str(wb_cachelist, max.level = 1)
new_cache <- wbcache()
gdp <- wbsearch(pattern = "gdp")


# Source: https://data.worldbank.org/indicator/NY.GDP.MKTP.CD?locations=AR

query <- wb(indicator = "NY.GDP.MKTP.CD",
            startdate = "1970",
            enddate = "2018",
            POSIXct=TRUE)

gdp <- query[c(1,3,7,8)]

colnames(gdp) <- c("wbcode3", "gdp", "country_name_wb", "date")

gdp$date <- as.Date(gdp$date)
gdp$gdp <- as.numeric(gdp$gdp)
# str(gdp)


mybase <- subset(gdp, wbcode3 == "ARG")
# 
# ggplot(mybase, aes(x=date, y=gdp))+
#   geom_line()


write.csv2(gdp, file="raw_data/GDP_data.csv", row.names = FALSE)
rm(query, gdp, mybase, new_cache)
print("gdp ok!")

