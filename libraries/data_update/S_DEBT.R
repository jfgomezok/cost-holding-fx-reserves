

#################################################################################
#############   ACTUALIZACION DE LA DEUDA  ######################################
#################################################################################

# library(wbstats)
# library(tidyverse)
# library(scales)
# library(kableExtra)

 
debt.a <- wb(indicator = "DT.DOD.DLXF.CD",
             startdate = "1990",
             enddate = "2018",
             POSIXct=TRUE)[c(1,3,7,8)]


debt.a1 <- wb(indicator = "DT.DOD.DPPG.CD",
              startdate = "1990",
              enddate = "2018",
              POSIXct=TRUE)[c(1,3,7,8)]

debt.a1a <- wb(indicator = "DT.DOD.OFFT.CD",
               startdate = "1990",
               enddate = "2018",
               POSIXct=TRUE)[c(1,3,7,8)]

debt.a1b <- wb(indicator = "DT.DOD.PRVT.CD",
               startdate = "1990",
               enddate = "2018",
               POSIXct=TRUE)[c(1,3,7,8)]

debt.a2 <- wb(indicator = "DT.DOD.DPNG.CD",
              startdate = "1990",
              enddate = "2018",
              POSIXct=TRUE)[c(1,3,7,8)]





colnames(debt.a) <- c("wbcode3", "debt_lt", "country.name", "date")
colnames(debt.a1) <- c("wbcode3", "debt_public", "country.name", "date")
colnames(debt.a1a) <- c("wbcode3", "debt_public_oc", "country.name", "date")
colnames(debt.a1b) <- c("wbcode3", "debt_public_pc", "country.name", "date")
colnames(debt.a2) <- c("wbcode3", "debt_private", "country.name", "date")

debt.a$wbcode3 <- as.factor(debt.a$wbcode3)
debt.a$country.name <- as.factor(debt.a$country.name)
debt.a1$wbcode3 <- as.factor(debt.a1$wbcode3)
debt.a1$country.name <- as.factor(debt.a1$country.name)
debt.a1a$wbcode3 <- as.factor(debt.a1a$wbcode3)
debt.a1a$country.name <- as.factor(debt.a1a$country.name)
debt.a1b$wbcode3 <- as.factor(debt.a1b$wbcode3)
debt.a1b$country.name <- as.factor(debt.a1b$country.name)
debt.a2$wbcode3 <- as.factor(debt.a2$wbcode3)
debt.a2$country.name <- as.factor(debt.a2$country.name)

# str(debt.a)
# str(debt.a1)
# str(debt.a1a)
# str(debt.a1b)
# str(debt.a2)


debt <- merge(debt.a, debt.a1, by=c("wbcode3","country.name", "date" ) , all=TRUE)
debt <- merge(debt, debt.a1a, by=c("wbcode3","country.name", "date" ) , all=TRUE)
debt <- merge(debt, debt.a1b, by=c("wbcode3","country.name", "date" ) , all=TRUE)
debt <- merge(debt, debt.a2, by=c("wbcode3","country.name", "date" ) , all=TRUE)
debt[debt == 0] <- NA

# str(debt)

debt2 <- debt %>%
  mutate( debt_lt = debt_lt / 1000000000) %>%
  mutate( debt_public = debt_public / 1000000000) %>%
  mutate( debt_public_oc = debt_public_oc / 1000000000) %>%
  mutate( debt_public_pc = debt_public_pc / 1000000000) %>%
  mutate( debt_private = debt_private / 1000000000) %>%
  mutate( debt_public_new = ifelse( is.na(debt_public), debt_public_oc + debt_public_pc, debt_public)) %>%
  mutate( debt_private_new = ifelse( is.na(debt_private), debt_lt - debt_public_new, debt_private))

# write.csv2(debt2, file="test.debt.csv", row.names = FALSE)

# 
# which(is.na(debt2), arr.ind = TRUE)
# 
# ggplot(debt2, aes(debt_private, debt_private_new))+
#   geom_point()


countries.ely.EL <- read.csv2("inputs/countries.csv")
colnames(countries.ely.EL) <- c("ifscode", "country_name_ifs", "wbcode3")
countries.ely <- as.character(unique(countries.ely.EL$wbcode3))

 

debt3 <- debt2 %>%
  select(wbcode3, country.name, date, debt_public_new, debt_private_new) %>%
  filter (wbcode3 %in% countries.ely)



country.list <- as.list(unique(debt3$country.name))
resume <- data.frame()


for (j in country.list) {
  
  # j <- "Argentina"
  
  df  <- debt2 %>%
    filter(country.name == j) %>%
    select(wbcode3, country.name, date, debt_public_new)
  
  anos_periodo <- as.numeric(format(max(df$date),"%Y")) - as.numeric(format(min(df$date),"%Y")) + 1
  
  
  df  <- debt2 %>%
    filter(country.name == j) %>%
    select(wbcode3, country.name, date, debt_public_new) %>%
    na.omit()

  
  obs_public_debt <- nrow(df)
  
  
  df2  <- debt2 %>%
    filter(country.name == j) %>%
    select(wbcode3, country.name, date, debt_private_new) %>%
    na.omit()
  
    obs_private_debt <- nrow(df2)

  
  resume.j <- data.frame(j, anos_periodo, obs_public_debt, obs_private_debt )
  
  resume <- rbind(resume, resume.j)
  
}

colnames(resume)[1] <- "Country"

resume <- resume %>%
  mutate( public_debt_pct = percent(obs_public_debt/anos_periodo)) %>%
  mutate( private_debt_pct = percent(obs_private_debt/anos_periodo)) 

table <- kable(resume[,c(1,2,5,6)],
      col.names = c("Country", "Numero de años del periodo", "Disponibilidad de Deuda Publica", "Disponibilidad de Deuda Privada")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "responsive"),
                full_width = F,
                position = "left")


# wbdebt_codes <- c("DT.DOD.ALLC.CD",  "DT.DOD.BLAT.CD",  "DT.DOD.BLTC.CD",  "DT.DOD.DECT.CD",
#   "DT.DOD.DIMF.CD",  "DT.DOD.DLXF.CD",  "DT.DOD.DPNG.CD",  "DT.DOD.DPPG.CD",
#   "DT.DOD.DSTC.CD",  "DT.DOD.MIBR.CD",  "DT.DOD.MIDA.CD",  "DT.DOD.MLAT.CD",
#   "DT.DOD.MLTC.CD",  "DT.DOD.OFFT.CD",  "DT.DOD.PBND.CD",  "DT.DOD.PCBK.CD",
#   "DT.DOD.PNGB.CD",  "DT.DOD.PNGC.CD",  "DT.DOD.PROP.CD",  "DT.DOD.PRVS.CD",
# #   "DT.DOD.PRVT.CD",  "DT.DOD.PUBS.CD",  "DT.DOD.PVLX.CD",  "DT.DOD.VTOT.CD")

# 
# ltdebt <- wb(indicator = "DT.DOD.DECT.CD.FC.US",
#                            POSIXct=TRUE)
#   
# ltdebt <- ltdebt[c(1,3,7,8)]
# 
# unique(private.debt$iso3c)
# unique(public.debt$iso3c)
# 
# total.debt <- merge(public.debt, private.debt, by=c("iso3c", "country", "date_ct"), all.x = TRUE)
# colnames(total.debt) <- c("wbcode3","country","date", "public_debt", "private_debt" )
# # str(total.debt)
# 
# unique(subset(total.debt, is.na(private_debt))$wbcode3)
# # total.debt[is.na(total.debt)] <- 0
# 
# total.debt <- total.debt %>%
#   mutate( public_debt = public_debt /1000000000) %>%
#   mutate( private_debt = private_debt/1000000000) %>%
#   mutate( total_debt =  public_debt + private_debt)

# colnames(debt.wb) <- c("wbcode3", "debt", "country_name_wb", "date")
# debt.wb$date <- as.Date(debt.wb$date)
# debt.wb$debt <- as.numeric(debt.wb$debt)/1000000000
# str(debt.wb)
# write.csv2(debt.wb, file="Entregables/Seccion3_regresiones/Data/debt.wb.csv", row.names = FALSE)



write.csv2(debt3, file="raw_data/total.debt.csv", row.names = FALSE)
rm(table, resume, resume.j, df, df2, debt3, debt2, debt.a2, debt.a1b, debt.a1a, debt.a1, debt.a, debt, countries.ely, countries.ely.EL, country.list, anos_periodo, j, obs_private_debt, obs_public_debt)
print("debt ok!")