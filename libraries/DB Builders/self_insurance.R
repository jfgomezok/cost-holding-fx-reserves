
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
DBSection3 <- embi.wb %>%
              filter(as.character(wbcode3) %in% countries.ely) %>%
              mutate(year = year(date))

DBSection3 <- merge(DBSection3, countries.ely.EL, by=c("wbcode3")) %>% as_tibble()

DBSection3 <- DBSection3 %>%
              select("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread") %>%
              mutate(spread = replace_na(spread, 0))



rm(embi.wb, countries.ely.EL, dlr_countries, countries.ely)

# str(DBSection3)


#################################################################
#-------- 10 Y E A R  U S    R A T E ------------------------
#################################################################



us10y <- read_csv2("raw_data/us10y.csv")
# str(us10y)

colnames(us10y) <- c("date", "us10y")

DBSection3 <- left_join(DBSection3, us10y,  by=c("date")) %>%
              select("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread", "us10y")


rm(us10y)


#################################################################
#----- R I S K   A V E R S I O N --------------------------
#################################################################


risk.aversion <- read_csv2("raw_data/risk.aversion.csv")
# str(risk.aversion)


DBSection3 <- left_join(DBSection3, risk.aversion, by=c("date")) %>%
              select("ifscode","wbcode2","wbcode3", "country_name_wb","country_name_ifs", "date","year" ,"spread", "us10y", "riskaversion")


rm(risk.aversion)





#################################################################
#-------- R E S E R V E S ----------------------------------- 
#################################################################




reserves.ifs <- read_csv2("raw_data/reserves.ifs.csv")
# str(reserves.ifs)


DBSection3 <- left_join(DBSection3, reserves.ifs, by=c("wbcode3", "date")) 

 

rm(reserves.ifs)




#################################################################
#------- D E B T    S T O C K S --------------------------------
#################################################################

debt.wb <- read_csv2("raw_data/debt_Monthly.csv")

# str(debt.wb)
# str(DBSection3)

DBSection3 <- left_join(DBSection3, debt.wb, by=c("date", "wbcode3"))


rm(debt.wb)

DBSection3[DBSection3 == 0] <- NA





#################################################################
#------- C R E D I T    R A T I N G S   --------- ---------------
#################################################################

ratings <- read_csv2("raw_data/ratings_scraper.csv") %>%
  select(date, wbcode3, rating)
# str(ratings)  


DBSection3 <- left_join(DBSection3, ratings, by=c("wbcode3", "date"))


rm(ratings)


#################################################################
#-------- G D P -------------------------------------------------
#################################################################



gdp.wb <- read_csv2("raw_data/GDP_Monthly.csv")

# str(gdp.wb)

DBSection3 <- left_join(DBSection3, gdp.wb, by=c("date", "wbcode3"))
# names(DBSection3)



# Arrange data set
DBSection3 <- DBSection3 %>% 
              arrange(date) %>% 
              arrange (wbcode3)



rm(gdp.wb)






#################################################################
#------ L I N E A R   T R A N F O R M A T I O N S ---------------
#################################################################
 

DBSection3 <- DBSection3 %>%
              mutate(public_debt = replace_na(public_debt, 0),
                     private_debt = replace_na(private_debt, 0),
                     total_debt = public_debt + private_debt)


DBSection3$public_debt[DBSection3$public_debt == 0] <- NA
DBSection3$private_debt[DBSection3$private_debt == 0] <- NA
DBSection3$total_debt[DBSection3$total_debt == 0] <- NA


# Log and ratios  ----------


DBSection3 <- DBSection3 %>%
              mutate (lspread       = log10(spread),
                      lriskaversion = log10(riskaversion),
                      lrating       = log10(rating),
                      lus10y        = log10(us10y),
                      lreserves     = log10(reserves),
                      lpublicdebt   = log10(public_debt),
                      lprivatedebt  = log10(private_debt),
                      ltotaldebt    = log10(total_debt),
                      R_Y           = reserves /MGDP,
                      PuD_Y         = public_debt /MGDP,
                      PrD_Y         = private_debt /MGDP,
                      D_Y           = total_debt /MGDP)



# Lags  ---------- 


DBSection3 <- DBSection3 %>%
              group_by(wbcode3) %>%
              mutate(lreserves_1    = dplyr::lag(x = lreserves, n = 1),
                     lpublicdebt_1  = dplyr::lag(x = lpublicdebt, n = 1),
                     lprivatedebt_1 = dplyr::lag(x = lprivatedebt, n = 1),
                     ltotaldebt_1   = dplyr::lag(x = ltotaldebt, n = 1))





# str(DBSection3)






#################################################################
#-------- O U T P U T S  ----------------------------------------
#################################################################







write_csv2(x    = DBSection3,
           path = "Outputs/self_insurance_db.csv")

write.dta(DBSection3,
          file = "Outputs/self_insurance_db.dta",
          convert.factors = "string")

# str(DBSection3)

print("Self Insurance Data Base Ok!!")



