

#################################################################################
#############   DEBT UPDATE SCRIPT  #############################################
#################################################################################

# library(wbstats)
# library(tidyverse)
# library(scales)
# library(kableExtra)

debt.a <- wb(indicator = "DT.DOD.DLXF.CD",
             startdate = "1990",
             enddate = "2018",
             POSIXct=TRUE)[c(1,3,7,8)] %>%
          set_names(c("wbcode3", "debt_lt", "country.name", "date"))


debt.a1 <- wb(indicator = "DT.DOD.DPPG.CD",
              startdate = "1990",
              enddate = "2018",
              POSIXct=TRUE)[c(1,3,7,8)] %>%
           set_names(c("wbcode3", "debt_public", "country.name", "date"))

debt.a1a <- wb(indicator = "DT.DOD.OFFT.CD",
               startdate = "1990",
               enddate = "2018",
               POSIXct=TRUE)[c(1,3,7,8)] %>%
            set_names(c("wbcode3", "debt_public_oc", "country.name", "date"))

debt.a1b <- wb(indicator = "DT.DOD.PRVT.CD",
               startdate = "1990",
               enddate = "2018",
               POSIXct=TRUE)[c(1,3,7,8)] %>%
            set_names(c("wbcode3", "debt_public_pc", "country.name", "date"))

debt.a2 <- wb(indicator = "DT.DOD.DPNG.CD",
              startdate = "1990",
              enddate = "2018",
              POSIXct=TRUE)[c(1,3,7,8)] %>%
            set_names(c("wbcode3", "debt_private", "country.name", "date"))



# str(debt.a1b)
# 
# debt.a$wbcode3 <- as.factor(debt.a$wbcode3)
# debt.a$country.name <- as.factor(debt.a$country.name)
# 
# debt.a1$wbcode3 <- as.factor(debt.a1$wbcode3)
# debt.a1$country.name <- as.factor(debt.a1$country.name)
# 
# debt.a1a$wbcode3 <- as.factor(debt.a1a$wbcode3)
# debt.a1a$country.name <- as.factor(debt.a1a$country.name)
# 
# debt.a1b$wbcode3 <- as.factor(debt.a1b$wbcode3)
# debt.a1b$country.name <- as.factor(debt.a1b$country.name)
# 
# debt.a2$wbcode3 <- as.factor(debt.a2$wbcode3)
# debt.a2$country.name <- as.factor(debt.a2$country.name)

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

# Parse number into billions
debt2 <-  debt %>%
  mutate( debt_lt = debt_lt / 1000000000,
          debt_public = debt_public / 1000000000,
          debt_public_oc = debt_public_oc / 1000000000,
          debt_public_pc = debt_public_pc / 1000000000,
          debt_private = debt_private / 1000000000,
          debt_public_new = ifelse( is.na(debt_public), debt_public_oc + debt_public_pc, debt_public),
          debt_private_new = ifelse( is.na(debt_private), debt_lt - debt_public_new, debt_private))




# Read original country list un Levy Yeyati (xxxx)
countries.ely.EL <- read_csv2("inputs/countries.csv") %>%
                    set_names(c("ifscode", "country_name_ifs", "wbcode3"))

countries.ely <- as.character(unique(countries.ely.EL$wbcode3))

debt3 <- debt2 %>%
         select(wbcode3, country.name, date, debt_public_new, debt_private_new) %>%
         filter (wbcode3 %in% countries.ely) %>%
         set_names(c('wbcode3', 'country.name', 'date', 'public_debt', 'private_debt'))



country.list <- as.list(unique(debt3$country.name))
resume <- data.frame()


for (j in country.list) {
  
  # j <- "Argentina"
  
  df  <- debt2 %>%
    filter(country.name == j) %>%
    select(wbcode3, country.name, date, debt_public_new)
  
  NumberYears <- as.numeric(format(max(df$date),"%Y")) - as.numeric(format(min(df$date),"%Y")) + 1
  
  
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

  
  resume.j <- data.frame(j, NumberYears, obs_public_debt, obs_private_debt )
  
  resume <- rbind(resume, resume.j)
  
}

colnames(resume)[1] <- "Country"

resume <- resume %>%
  mutate( public_debt_pct = percent(obs_public_debt/NumberYears)) %>%
  mutate( private_debt_pct = percent(obs_private_debt/NumberYears)) 

kable(resume[,c(1,2,5,6)],
      col.names = c("Country", "Number of years of the period", "Public Debt Data", "Private Debt Data")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "responsive"),
                full_width = F,
                position = "left")




# Export  -----

write_csv2(x = debt3,
           path = "raw_data/total.debt.csv")


rm(resume, NumberYears, resume.j, df, df2, debt3, debt2, debt.a2, debt.a1b, debt.a1a, debt.a1, debt.a, debt, countries.ely, countries.ely.EL, country.list, j, obs_private_debt, obs_public_debt)
print("debt ok!")