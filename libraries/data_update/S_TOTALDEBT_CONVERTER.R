

###### MONTHLY DEBT CREATION #######


# library(splines)
# library(ggplot2)

total.debt <- read_csv2("raw_data/total.debt.csv")
total.debt[is.na(total.debt)] <- 0
# str(total.debt)


country.list <- as.character(unique(total.debt$wbcode3))


debt.monthly <- data.frame(wbcode3 = as.character(),
                           date = as.Date(as.character()),
                           public_debt = as.numeric(),
                           private_debt = as.numeric(),
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
  splineout.public <- spline(x=debt.yearly$aux, y=debt.yearly$public_debt, n=spline.n)
  splineout.private <- spline(x=debt.yearly$aux, y=debt.yearly$private_debt, n=spline.n)

  
  debt.bymonth <- data.frame(wbcode3 = i,
                             auxdate = splineout.public$x,
                             public_debt = splineout.public$y,
                             private_debt = splineout.private$y)
  
  mindate <- as.Date(min(debt.yearly$date))
  debt.bymonth$date <- seq.Date(from = mindate, length.out = nrow(debt.bymonth), by = "month")
  
  debt.monthly <- rbind(debt.monthly, debt.bymonth[, c("wbcode3", "date", "public_debt", "private_debt")])
  
}

# str(debt.monthly)
# str(total.debt)

total.debt$date <- as.Date(format(total.debt$date, "%Y-12-01"))

# TEST CONSISTENCY:
# merge(total.debt, debt.monthly,
#       by=c("wbcode3", "date"),
#       all.x = TRUE, all.y=TRUE) %>%
# filter(wbcode3 == 'BRA') %>%
# ggplot(aes(x=date))+
# geom_point(aes(y=public_debt.x))+
# geom_line(aes(y=public_debt.y))

write_csv2(x    = debt.monthly,
           path = "raw_data/Debt_Monthly.csv")

rm(total.debt, debt.monthly, debt.yearly,aux, i, mindate, debt.bymonth, country.list, splineout.private, splineout.public, spline.n)
print("monthly debt ok!")
