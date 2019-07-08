

###### MONTHLY DEBT CREATION #######


# library(splines)
# library(ggplot2)

total.debt <- read.csv2("raw_data/total.debt.csv")
total.debt[is.na(total.debt)] <- 0
total.debt$date <- as.Date(total.debt$date)
# str(total.debt)


country.list <- as.character(unique(total.debt$wbcode3))


debt.monthly <- data.frame(wbcode3 = as.character(),
                           date = as.Date(as.character()),
                           debt_public_new = as.numeric(),
                           debt_private_new = as.numeric(),
                           stringsAsFactors = FALSE)


for (i in country.list) {
  # cat(" i:", i)
   # i <- "ARG"
  debt.yearly <- subset(total.debt, wbcode3 == i)
  
  debt.yearly <- debt.yearly %>% arrange(date)
  
  debt.yearly$date <- as.Date(debt.yearly$date)
  debt.yearly$date <- format (debt.yearly$date, "%Y-12-01")
  
  aux <- seq(from = 12, to = 12*nrow(debt.yearly), by = 12)
  debt.yearly$aux <- aux
  
  # el "n" del spline tiene que ser: cant de años de datos + (meses a agregar por año * (cantidad de años -1))
  spline.n <- nrow(debt.yearly) + (11* (nrow(debt.yearly) - 1))
  splineout.public <- spline(x=debt.yearly$aux, y=debt.yearly$debt_public_new, n=spline.n)
  splineout.private <- spline(x=debt.yearly$aux, y=debt.yearly$debt_private_new, n=spline.n)

  
  debt.bymonth <- data.frame(wbcode3 = i,
                             auxdate = splineout.public$x,
                             debt_public_new = splineout.public$y,
                             debt_private_new = splineout.private$y)
  
  mindate <- as.Date(min(debt.yearly$date))
  debt.bymonth$date <- seq.Date(from = mindate, length.out = nrow(debt.bymonth), by = "month")
  
  debt.monthly <- rbind(debt.monthly, debt.bymonth[, c("wbcode3", "date", "debt_public_new", "debt_private_new")])
  
}

# table(debt.monthly$wbcode3)


# str(debt.monthly)
# str(total.debt)

total.debt$date <- as.Date(format(total.debt$date, "%Y-12-01"))
test.consistency <- merge(total.debt, debt.monthly, by=c("wbcode3", "date"), all.x = TRUE, all.y=TRUE)
# write.csv2(test.consistency, file="test.consistency.csv", row.names = FALSE)

country <- "PER"
# ggplot( test.consistency[test.consistency$wbcode3 == country, ])+
#    geom_point(aes(x=date, y=debt_public_new.x))+
#   geom_line(aes(x=date, y=debt_public_new.y))

write.csv2(debt.monthly, file="raw_data/Debt_Monthly.csv", row.names = FALSE)
rm(country, test.consistency, total.debt, debt.monthly, debt.yearly,aux, i, mindate, debt.bymonth, country.list, splineout.private, splineout.public, spline.n)
print("monthly debt ok!")
