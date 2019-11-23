
#TODO: ADD AN INTRO



#################################################################
#-----  C O U N T R I E S -------------------------------------
#################################################################



# Lecture of original countries included in Levy Yeyati (2008)
countries.ely.EL <- read_csv2("Inputs/countries.csv")
colnames(countries.ely.EL) <- c("ifscode", "country_name_ifs", "wbcode3")
countries.ely <- as.character(unique(countries.ely.EL$wbcode3))


#################################################################
#----- E M B I ----------------------------------------------------
#################################################################

# Lecture of EMBI data
embi.wb <- read_csv2("raw_data/embi.wb.csv")
colnames(embi.wb)[4] <- "country_name_wb"
# str(embi.wb)


# REMOVE DOLLARIZED COUNTRIES
dlr_countries <- c("SLV", "ECU", "PAN")
embi.wb <- embi.wb %>%
  filter (!wbcode3 %in% dlr_countries)




# We work only with countries covered in Levy Yeyati (2008)
base.paper <- embi.wb %>% filter(as.character(wbcode3) %in% countries.ely)

base.paper$year <- as.numeric(format( base.paper$date, "%Y"))

base.paper <- merge(base.paper, countries.ely.EL, by=c("wbcode3"))

base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread")]

# str(base.paper)

# which(is.na(base.paper), arr.ind = TRUE)

# Replace 'NA' for zeros
base.paper$spread <- ifelse(base.paper$spread == 0, NA, base.paper$spread)

# countries1 <- as.character(unique(base.paper$wbcode3))
# NA1_embi <- as.character(unique(subset(base.paper, is.na(spread))$wbcode3))

rm(embi.wb, countries.ely.EL, dlr_countries, countries.ely)

# str(base.paper)


#################################################################
#-------- 10 Y E A R  U S    R A T E ------------------------
#################################################################



us10y <- read_csv2("raw_data/us10y.csv")
# str(us10y)

colnames(us10y) <- c("date", "us10y")

base.paper <- merge(base.paper, us10y, by=c("date"), all.x = TRUE)

base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread", "us10y")]

# countries2 <- as.character(unique(base.paper$wbcode3))
# NA2_us10 <- as.character(unique(subset(base.paper, is.na(us10y))$wbcode3))

rm(us10y)


#################################################################
#----- R I S K   A V E R S I O N --------------------------
#################################################################


risk.aversion <- read_csv2("raw_data/risk.aversion.csv")
# str(risk.aversion)


base.paper <- merge(base.paper, risk.aversion, by=c("date"), all.x = TRUE)

base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread", "us10y", "riskaversion")]


# countries3 <- as.character(unique(base.paper$wbcode3))
# NA3_risk <- as.character(unique(subset(base.paper, is.na(riskaversion))$wbcode3))


rm(risk.aversion)





#################################################################
#-------- R E S E R V E S ----------------------------------- 
#################################################################




reserves.ifs <- read_csv2("raw_data/reserves.ifs.csv")
# str(reserves.ifs)


base.paper <- merge(base.paper, reserves.ifs, by=c("wbcode3", "date"), all.x = TRUE) 
# OJO QUE QUEDO AFUERA UN PAIS : "CIV"

# 
# base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year","spread","reserves", "us10y", "riskaversion")]


rm(reserves.ifs)

# countries4 <- as.character(unique(base.paper$wbcode3))
# NA4_reserves <- as.character(unique(subset(base.paper, is.na(reserves))$wbcode3))

# base.paper[base.paper$wbcode3 == "CIV",]





#################################################################
#------- D E B T    S T O C K S --------------------------------
#################################################################

debt.wb <- read_csv2("raw_data/debt_Monthly.csv")

# str(debt.wb)
# str(base.paper)

base.paper <- merge (base.paper, debt.wb, by=c("date", "wbcode3"), all.x = TRUE)

base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year","spread","reserves", "us10y", "riskaversion", "public_debt","private_debt")]

rm(debt.wb)

base.paper[base.paper == 0] <- NA

# countries5 <- as.character(unique(base.paper$wbcode3))
# NA5_debtpublic <- as.character(unique(subset(base.paper, is.na(public_debt))$wbcode3))
# NA6_debtprivate <- as.character(unique(subset(base.paper, is.na(private_debt))$wbcode3))

# base.paper[base.paper$wbcode3 == "KOR",]





#################################################################
#------- C R E D I T    R A T I N G S   --------- ---------------
#################################################################

ratings <- read_csv2("raw_data/ratings_scraper.csv") %>%
  select(date, wbcode3, rating)
# str(ratings)  


base.paper <- merge(base.paper, ratings, by=c("wbcode3", "date"), all.x = TRUE)


base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year","spread","reserves", "us10y", "riskaversion", "public_debt","private_debt","rating")]

rm(ratings)


#################################################################
#-------- G D P -------------------------------------------------
#################################################################



gdp.wb <- read_csv2("raw_data/GDP_Monthly.csv")

# str(gdp.wb)

base.paper <- merge (base.paper, gdp.wb, by=c("date", "wbcode3"), all.x = TRUE)


base.paper <- base.paper[c("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year","spread","reserves", "us10y", "riskaversion", "public_debt","private_debt","rating","MGDP")]


# Arrange data set
base.paper <- base.paper %>% 
              arrange(date) %>% 
              arrange (wbcode3)



rm(gdp.wb)






#################################################################
#------ L I N E A R   T R A N F O R M A T I O N S ---------------
#################################################################

base.paper$public_debt[is.na(base.paper$public_debt)] <- 0
base.paper$private_debt[is.na(base.paper$private_debt)] <- 0
base.paper <- base.paper %>% mutate (total_debt = public_debt + private_debt) 

base.paper$public_debt[base.paper$public_debt == 0] <- NA
base.paper$private_debt[base.paper$private_debt == 0] <- NA
base.paper$total_debt[base.paper$total_debt == 0] <- NA

base.paper <- base.paper %>%
  mutate (lspread      = log10(spread),
          lriskaversion = log10(riskaversion),
          lrating      = log10(rating),
          lus10y       = log10(us10y),
          lreserves    = log10(reserves),
          lpublicdebt  = log10(public_debt),
          lprivatedebt = log10(private_debt),
          ltotaldebt   = log10(total_debt),
          R_Y          = reserves /MGDP,
          PuD_Y        = public_debt /MGDP,
          PrD_Y        = private_debt /MGDP,
          D_Y          = total_debt /MGDP)






for (i in 1:dim(base.paper)[1]) {
  # i <- 2
  if( i == 1 )
  {base.paper$lreserves_1[i] <- NA}
  else
  {  
    if ( base.paper$wbcode3[i] == base.paper$wbcode3[i-1])
    {base.paper$lreserves_1[i] <- base.paper$lreserves[i-1]}
    else {base.paper$lreserves_1[i] <- NA}
  }}


for (i in 1:dim(base.paper)[1]) {
  # i <- 2
  if( i == 1 )
  {base.paper$lpublicdebt_1[i] <- NA}
  else
  {  
    if ( base.paper$wbcode3[i] == base.paper$wbcode3[i-1])
    {base.paper$lpublicdebt_1[i] <- base.paper$lpublicdebt[i-1]}
    else {base.paper$lpublicdebt_1[i] <- NA}
  }}




for (i in 1:dim(base.paper)[1]) {
  # i <- 2
  if( i == 1 )
  {base.paper$lprivatedebt_1[i] <- NA}
  else
  {  
    if ( base.paper$wbcode3[i] == base.paper$wbcode3[i-1])
    {base.paper$lprivatedebt_1[i] <- base.paper$lprivatedebt[i-1]}
    else {base.paper$lprivatedebt_1[i] <- NA}
  }}



for (i in 1:dim(base.paper)[1]) {
  # i <- 2
  if( i == 1 )
  {base.paper$ltotaldebt_1[i] <- NA}
  else
  {  
    if ( base.paper$wbcode3[i] == base.paper$wbcode3[i-1])
    {base.paper$ltotaldebt_1[i] <- base.paper$ltotaldebt[i-1]}
    else {base.paper$ltotaldebt_1[i] <- NA}
  }}


rm(i)

# str(base.paper)






#################################################################
#-------- S A L I D A S ----------------------------------------
#################################################################







write_csv2(x    = base.paper,
           path = "Outputs/self_insurance_db.csv")

write.dta(base.paper,
          file = "Outputs/self_insurance_db.dta",
          convert.factors = "string")

# str(base.paper)

print("base actualizada ok!!")



