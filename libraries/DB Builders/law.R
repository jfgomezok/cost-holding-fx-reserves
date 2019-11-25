

######################################################################
#####   L E A N I N G    A G A I N S T     T H E     W I N D    ######
######################################################################




######################################################################
#-------- RESERVES AND FX --------------------------------------------
######################################################################


#lectura de la data ifm
my_df <- read_csv2("raw_data/Reserves_NER.csv") %>% as_tibble()
# my_df$date <- as.Date(my_df$date)
# str(my_df)

countries.wb <- read_csv2("raw_data/CountriesWB.csv") 

my_df <- left_join(my_df, countries.wb[1:2], by = c("country.abb" = "wbcode2")) %>%
         set_names(c('date',"wbcode2" ,"NER", "reserves","wbcode3")) %>%
         select("wbcode2","wbcode3", "date","NER", "reserves") %>%
         filter(between(date, ymd('1998-12-01'), ymd("2018-12-01")))

# stargazer(my_df, type="text")

rm(countries.wb)



######################################################################
#############     LIBOR     ##########################################
######################################################################

libor <- read_csv2("raw_data/libor.csv")
# str(libor)


my_df <- left_join(my_df, libor, by = "date")

my_df <- my_df %>%
  arrange (date) %>%
  arrange (wbcode3)


rm(libor)

# Net Reserves:

my_df <- my_df %>%
         mutate(net.reserves = reserves / (1+ libor.TNA/100))



start.date <- min(my_df$date)



# change in fx, monthly basis

my_df <- my_df %>%
  group_by(wbcode3) %>%
  mutate(NER.monthly.change          = NER - dplyr::lag(x = NER, n = 1),
         net.reserves.monthly.change = net.reserves - dplyr::lag(x = net.reserves, n = 1))





######################################################################
####################      CARRY CIP     ##############################
######################################################################

implied.ndf <- read_csv2("Inputs/CIP.csv")   # BLOOMBERG!!

implied.ndf <- gather(implied.ndf, date, TNA, 3:172)
colnames(implied.ndf) <- c("country.name","wbcode2","date","TNA.Carry")

implied.ndf$date <- gsub("X","",implied.ndf$date)
implied.ndf$date <- as.Date(implied.ndf$date, "%d/%m/%Y")

implied.ndf$TNA.Carry <- as.numeric(implied.ndf$TNA.Carry)


# country.list <- read.delim("Entregables/Seccion4_LAW/Data/countries.txt", sep = "\t",header = TRUE)
# implied.ndf <- merge(implied.ndf, country.list)

implied.ndf <- implied.ndf %>%
  arrange( date ) %>%
  arrange (country.name)



######################################################################
###################     EMBI       ###################################
######################################################################

embi.wb <- read_csv2("raw_data/embi.wb.csv")
# embi.wb$date <- as.Date(embi.wb$date)
colnames(embi.wb)[4] <- "country_name_wb"




##########################################################
#---------T E R M    P R E M I U M -----------------------
##########################################################



US_tp <- read_csv2("raw_data/US_tp.csv")
# US_tp$date <- as.Date(US_tp$date)
colnames(US_tp)[2] <- "us_tp"
# str(US_tp)




######################################################################
#--------- G D P -----------------------------------------------------
######################################################################

#lectura de la data fed st. louis
gdp <- read_csv2("raw_data/GDP_Monthly.csv")
# gdp$date <- as.Date(gdp$date)
# str(gdp)




######################################################################
# ----------- FINAL TABLE --------------------------------------------
######################################################################




my_df <- left_join(my_df, implied.ndf[,c(2:4)], by = c("date","wbcode2"))
my_df <- left_join(my_df, embi.wb[,c(1:3,5)], by = c("date","wbcode3", "wbcode2"))
my_df <- left_join(my_df, US_tp, by = c("date"))
my_df <- left_join(my_df, gdp, by=c("date","wbcode3"))

stargazer(as.data.frame(my_df), type = 'text')

my_df <- my_df %>%
  arrange (date) %>%
  arrange (wbcode3)



# names(my_df)


rm(gdp, implied.ndf, embi.wb, US_tp)



######################################################################
# --------- calculations --------------------------------------------
######################################################################


my_df <- my_df %>%
  mutate(TEM.cip    = - ( (  (1+ TNA.Carry) ^ (1/12) ) -1),
         TNA.spread = spread/100 + us_tp,
         TEM.spread = - ( (  (1+ TNA.spread/100) ^ (1/12) ) -1))


unique(year(my_df$date))



my_df <- my_df %>%
  filter(date>= "2004-11-01") %>%
  group_by(wbcode3) %>%
  mutate(net.reserves.monthly.change               = replace_na(net.reserves.monthly.change, 0),
         net.reserves.monthly.change.acum          = cumsum(net.reserves.monthly.change),
         FX.purchases.valuation.effect.lcu.monthly = net.reserves.monthly.change.acum *  NER.monthly.change,
         Valuation.effect.monthly                  = ifelse(is.na(FX.purchases.valuation.effect.lcu.monthly/ NER), 0, FX.purchases.valuation.effect.lcu.monthly/ NER),
         Valuation.effect.monthly.acum             = cumsum(Valuation.effect.monthly),
         CarryCIP.effect.monthly                   = ifelse(is.na(TEM.cip * net.reserves.monthly.change.acum), 0, TEM.cip * net.reserves.monthly.change.acum),
         CarrySpread.effect.monthly                = TEM.spread * net.reserves.monthly.change.acum,
         CarryCIP.effect.monthly.acum              = cumsum(CarryCIP.effect.monthly), 
         CarrySpread.effect.monthly.acum           = cumsum(CarrySpread.effect.monthly), 
         PNL.total.monthly.acum1                   = Valuation.effect.monthly.acum + CarryCIP.effect.monthly.acum,
         PNL.total.monthly.acum2                   = Valuation.effect.monthly.acum + CarrySpread.effect.monthly.acum)




######################################################################
# -------   EXPORT ---------------------------------------------------
######################################################################





write.csv2(my_df, file="Outputs/law_db.csv",
           row.names = FALSE)

write.dta(my_df,
          file = "Outputs/law_db.dta",
          convert.factors = "string")


print("base actualizada ok!!")


