

###### MONTHLY GDP CREATION #######


# library(splines)
# library(ggplot2)

gdp.wb <- read.csv2("raw_data/GDP_data.csv")

country.list <- as.character(unique(gdp.wb$wbcode3))


gdp.monthly <- data.frame(wbcode3 = as.character(),
                          date = as.Date(as.character()),
                          MGDP = as.numeric(),
                          stringsAsFactors = FALSE)


for (i in country.list) {
    # cat(" i:", i)
    # i <- "BRA" "ARG"
    gdp.yearly <- subset(gdp.wb, wbcode3 == i)
    
    orden <- order(gdp.yearly$date)
    gdp.yearly <- gdp.yearly[orden, ]
    
    gdp.yearly$date <- as.Date(gdp.yearly$date)
    gdp.yearly$date <- format (gdp.yearly$date, "%Y-12-01")
    
    aux <- seq(from = 12, to = 12*nrow(gdp.yearly), by = 12)
    gdp.yearly$aux <- aux
    
    # el "n" del spline tiene que ser: cant de años de datos + (meses a agregar por año * (cantidad de años -1))
    spline.n <- nrow(gdp.yearly) + (11* (nrow(gdp.yearly) - 1))
    splineout <- spline(x=gdp.yearly$aux, y=gdp.yearly$gdp, n=spline.n)
    
    gdp.bymonth <- data.frame(wbcode3 = i, auxdate = splineout$x, MGDP = splineout$y)
    
    mindate <- as.Date(min(gdp.yearly$date))
    gdp.bymonth$date <- seq.Date(from = mindate, length.out = nrow(gdp.bymonth), by = "month")
    
    gdp.monthly <- rbind(gdp.monthly, gdp.bymonth[, c("wbcode3", "date", "MGDP")])

}

# table(gdp.monthly$wbcode3)

country <- "ARG"
# ggplot( gdp.monthly[gdp.monthly$wbcode3 == country, ], aes(x = date, y = MGDP) ) +
#   geom_line()

write.csv2(gdp.monthly, file="raw_data/GDP_Monthly.csv", row.names = FALSE)
rm(gdp.monthly, gdp.yearly,aux, country, i, mindate, orden, gdp.bymonth,gdp.wb, country.list, splineout, spline.n)
print("monthly gdp ok!")
