

######################################################################
#####   L E A N I N G    A G A I N S T     T H E     W I N D    ######
#################        S E T U P      ##############################
######################################################################


rm(list = ls()) # limpiar memoria

options(    tikzDefaultEngine = "xetex",   # Acentos en tablas
            java.parameters = "-Xmx8000m", # Evitar notación científica
            knitr.kable.NA = 's/d')

Sys.setlocale("LC_ALL","Spanish")

source("Librerias/Load_packages.R")

fecha.salida <- format( as.Date(Sys.Date()) , "%Y%m%d" )





######################################################################
#-------- RESERVES AND FX --------------------------------------------
######################################################################


#lectura de la data ifm
my_df <- read.csv2("raw_data/Reserves_NER.csv")
my_df$date <- as.Date(my_df$date)
# str(my_df)


countries.imf <- read.csv2("Inputs/imfcountriesmetadata.csv")
my_df <- merge(my_df, countries.imf[3:4], by.x="country.abb",  by.y = "Country.ISO.2.Code")

colnames(my_df) <- c("wbcode2", "date","NER", "reserves","wbcode3")
my_df <- my_df[c("wbcode2","wbcode3", "date","NER", "reserves")]

my_df <- subset(my_df, date >= "1998-12-01" & date <= "2018-12-01")

# stargazer(my_df, type="text")

rm(countries.imf)



######################################################################
#############     LIBOR     ##########################################
######################################################################

#lectura de la data fed st. louis
libor <- read.csv2("raw_data/libor.csv")
libor$date <- as.Date(libor$date)
# str(libor)


my_df <- merge(my_df, libor, by.x = "date", by.y = "date", sort = FALSE)

my_df <- my_df %>%
  arrange (date) %>%
  arrange (wbcode3)


rm(libor)

my_df$net.reserves <- (my_df$reserves / (1+ my_df$libor/100))


start.date <- min(my_df$date)



# change in fx, monthly basis
for (i in 1:dim(my_df)[1]) {
  
  if ( my_df$date[i] == start.date)
  {my_df$NER.monthly.change[i] <- NA}
  else {my_df$NER.monthly.change[i] <- (my_df$NER[i] - my_df$NER[i-1])}
}


# change in net reserves, monthly basis
for (i in 1:dim(my_df)[1]) {
  
  if ( my_df$date[i] == start.date)
  {my_df$net.reserves.monthly.change[i] <- NA}
  else{my_df$net.reserves.monthly.change[i] <- (my_df$net.reserves[i] - my_df$net.reserves[i-1])}
}


rm(i)




######################################################################
####################      CARRY CIP     ##############################
######################################################################

implied.ndf <- read.csv2("Inputs/NDF.test.csv")   # DATA DE BLOOMBERG!!
implied.ndf <- gather(implied.ndf, date, TNA, 3:172)
colnames(implied.ndf) <- c("country.name","wbcode2","date","TNA.Carry")
implied.ndf$date <- gsub("X","",implied.ndf$date)
implied.ndf$date <- as.Date(implied.ndf$date, "%d.%m.%Y")
implied.ndf$country.name <- as.factor(implied.ndf$country.name)
implied.ndf$wbcode2 <- as.factor(implied.ndf$wbcode2)
implied.ndf$TNA.Carry <- as.numeric(implied.ndf$TNA.Carry)


# country.list <- read.delim("Entregables/Seccion4_LAW/Data/countries.txt", sep = "\t",header = TRUE)
# implied.ndf <- merge(implied.ndf, country.list)

implied.ndf <- implied.ndf %>%
  arrange( date ) %>%
  arrange (country.name)

# str(implied.jfg)



######################################################################
###################     EMBI       ###################################
######################################################################

embi.wb <- read.csv2("raw_data/embi.wb.csv")
embi.wb$date <- as.Date(embi.wb$date)
colnames(embi.wb)[4] <- "country_name_wb"




##########################################################
#---------T E R M    P R E M I U M -----------------------
##########################################################



US_tp <- read.csv2("raw_data/US_tp.csv")
US_tp$date <- as.Date(US_tp$date)
colnames(US_tp)[2] <- "us_tp"
# str(US_tp)




######################################################################
#--------- G D P -----------------------------------------------------
######################################################################

#lectura de la data fed st. louis
gdp <- read.csv2("raw_data/GDP_Monthly.csv")
gdp$date <- as.Date(gdp$date)
gdp$MGDP <- gdp$MGDP /1000000 
# str(gdp)




######################################################################
# ----------- FINAL TABLE --------------------------------------------
######################################################################




my_df <- merge(my_df, implied.ndf, by = c("date","wbcode2"))
my_df <- merge(my_df, embi.wb, by = c("date","wbcode3", "wbcode2"), all.x = TRUE)
my_df <- merge(my_df, US_tp, by = c("date"), all.x = TRUE)
my_df <- merge(my_df, gdp, by=c("date","wbcode3"), all.x = TRUE)


my_df <- my_df %>%
  arrange (date) %>%
  arrange (wbcode3)



# names(my_df)

my_df <- my_df[,c("wbcode3","country.name","date","NER","reserves","libor","MGDP","TNA.Carry","spread","us_tp","net.reserves","NER.monthly.change","net.reserves.monthly.change")]

rm(gdp, implied.ndf)



######################################################################
# --------- calculations --------------------------------------------
######################################################################


my_df <- my_df %>%
  mutate(TEM.cip    = - ( (  (1+ TNA.Carry) ^ (1/12) ) -1),
         TNA.spread = spread/100 + us_tp,
         TEM.spread = - ( (  (1+ TNA.spread/100) ^ (1/12) ) -1))



start.date <- min(my_df$date)

# change in reserves accumulated, monthly basis
for (i in 1:dim(my_df)[1]) {
  
  if ( my_df$date[i] == start.date)
  {my_df$net.reserves.monthly.change.acum[i] <- my_df$net.reserves.monthly.change[i]}
  
  else {my_df$net.reserves.monthly.change.acum[i] <- my_df$net.reserves.monthly.change[i]+
    my_df$net.reserves.monthly.change.acum[i-1]}
}


# FX valuation effect in local currency
my_df$FX.purchases.valuation.effect.lcu.monthly <- my_df$net.reserves.monthly.change.acum * my_df$NER.monthly.change



# FX valuation effect in USD
my_df$Valuation.effect.monthly <- my_df$FX.purchases.valuation.effect.lcu.monthly /my_df$NER


# P&L Valuation Effect acum
for (i in 1:dim(my_df)[1]) {
  if ( my_df$date[i] == start.date)
  {my_df$Valuation.effect.monthly.acum[i] <- my_df$Valuation.effect.monthly[i]}
  
  else {my_df$Valuation.effect.monthly.acum[i] <- my_df$Valuation.effect.monthly.acum[i-1] +
    my_df$Valuation.effect.monthly[i]}
}


# P&L Carry 
my_df$CarryCIP.effect.monthly <- my_df$TEM.cip * my_df$net.reserves.monthly.change.acum
my_df$CarrySpread.effect.monthly <- my_df$TEM.spread * my_df$net.reserves.monthly.change.acum



# P&L Carry USD (acum)
for (i in 1:dim(my_df)[1]) {
  if ( my_df$date[i] == start.date)
  {my_df$CarryCIP.effect.monthly.acum[i] <- my_df$CarryCIP.effect.monthly[i]}
  else
  {my_df$CarryCIP.effect.monthly.acum[i] <- my_df$CarryCIP.effect.monthly[i] + my_df$CarryCIP.effect.monthly.acum[i-1]}
}



for (i in 1:dim(my_df)[1]) {
  if ( my_df$date[i] == start.date)
  {my_df$CarrySpread.effect.monthly.acum[i] <- my_df$CarrySpread.effect.monthly[i]}
  else
  {my_df$CarrySpread.effect.monthly.acum[i] <- my_df$CarrySpread.effect.monthly[i] + my_df$CarrySpread.effect.monthly.acum[i-1]}
}



# P&L Total USD (acum)
my_df$PNL.total.monthly.acum1 <- my_df$Valuation.effect.monthly.acum + my_df$CarryCIP.effect.monthly.acum
my_df$PNL.total.monthly.acum2 <- my_df$Valuation.effect.monthly.acum + my_df$CarrySpread.effect.monthly.acum


rm(i,start.date)



######################################################################
# -------   EXPORT ---------------------------------------------------
######################################################################





write.csv2(my_df, file="Outputs/law_db.csv",
           row.names = FALSE)

write.dta(my_df,
          file = "Outputs/law_db.dta",
          convert.factors = "string")


print("base actualizada ok!!")


