

#################################################################################
#############   CURRENT ACCOUNT - FINANCIAL ACCOUNT  UPDATE SCRIPT ##############
#################################################################################

fdi_gdp_code <- "BX.KLT.DINV.WD.GD.ZS"
ca_gdp_code <- "BN.CAB.XOKA.GD.ZS"

labels <- c(
  "capital_account",
  "financial_account"
)

codes <- c(
  "capital_account_usd_code" = "BN.TRF.KOGT.CD",
  "financial_account_usd_code" = "BN.FIN.TOTL.CD"
  )

# str(codes)

external_data <- tibble(wbcode3 = NA,
                        date = NA,
                        Mvalue  = NA)


for (i in 1:2) {
  
  # i <- 2
  
  query <- wb(indicator = codes[i],
              startdate = "1990",
              enddate = "2019",
              POSIXct=TRUE
              ) %>% as_tibble()
  
  query_db <- query %>% as_tibble() %>% 
    select(iso3c, value, country, date_ct) %>%
    set_names(c("wbcode3", "value", "country_name", "date"))
  
  
  country.list <- as.character(unique(query_db$wbcode3))
  
  
  monthly_data <- tibble(wbcode3 = as.character(),
                         date = as.Date(as.character()),
                         MValue = as.numeric()
                         )
  
  
  for (j in country.list) {
    
    # j <- "BRA"
    
    temp <- query_db %>%
      filter(wbcode3 == j) %>% 
      arrange(date)
    
    temp$date <- format (temp$date, "%Y-12-01")
    
    aux <- seq(from = 12, to = 12*nrow(temp), by = 12)
    temp$aux <- aux
    
    # el "n" del spline tiene que ser: cant de años de datos + (meses a agregar por año * (cantidad de años -1))
    spline.n <- nrow(temp) + (11* (nrow(temp) - 1))
    splineout <- spline(x=temp$aux, y=temp$value, n=spline.n)
    
    temp2 <- tibble(wbcode3 = j,
                    auxdate = splineout$x,
                    MValue  = splineout$y
                    )
    
    mindate <- as.Date(min(temp$date))
    temp2$date <- seq.Date(from = mindate, length.out = nrow(temp2), by = "month")
    
    monthly_data <- rbind(monthly_data, temp2[, c("wbcode3", "date", "MValue")])
    
    
    
    
  }
  
  assign(x = labels[i], value = monthly_data)
  
  
  
  
}


colnames(capital_account)[3] <- "capital_account"
colnames(financial_account)[3] <- "financial_account"

external_data <- full_join(capital_account, financial_account,  by=c("wbcode3", "date"))



# Lecture of GDP data
gdp.wb <- read_csv2("raw_data/GDP_Monthly.csv")

external_data_gdp <- left_join(external_data, gdp.wb, by=c("date", "wbcode3"))

external_data_gdp <- external_data_gdp %>% 
  mutate(
    MGDP = MGDP * 1000,
    capital_account = capital_account / 1000000,
    financial_account = financial_account / 1000000,
    capacc_gdp = capital_account / MGDP,
    finacc_gdp = financial_account / MGDP
  )


chart <- external_data_gdp %>% select(wbcode3, date, capacc_gdp, finacc_gdp) %>% 
  gather(variable, value, -wbcode3, -date)

# Sandbox:
ggplot() + 
  geom_point(
    data = external_data_gdp %>%
           filter(wbcode3 %in% c("ARG", "MEX", "BRA", "TUR")
                  & month(date) ==12 ),
    mapping = aes(x = capacc_gdp, y = finacc_gdp, color=wbcode3) 
  )



write_csv2(x    = ca.monthly,
           path = "raw_data/current_account.wb.csv")


rm(ca.monthly, temp,  mindate)
print("external accounts ok!")
