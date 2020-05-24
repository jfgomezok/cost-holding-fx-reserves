#################################################################################
#############   DATA UPDATE  ####################################################
#################################################################################

#  RUN ALL LINES

#Creation of raw_data folder
if (!file.exists(file.path("raw_data"))){dir.create(file.path("raw_data"))}

#Countries
source("libraries/data_update/S_COUNTRIES2.R")

#Data from St Louis FED (API key required)
source("libraries/data_update/S_US10y.R")
source("libraries/data_update/S_RISKAVERSION.R")
source("libraries/data_update/S_US_TERM_PREMIUM.R")
source("libraries/data_update/S_LIBOR.R")

#Data from World Bank
source("libraries/data_update/S_EMBI.R")
source("libraries/data_update/S_DEBT.R")
source("libraries/data_update/S_TOTALDEBT_CONVERTER.R")
source("libraries/data_update/S_GDP.R") 
source("libraries/data_update/S_GDP_CONVERTER.R")
source("libraries/data_update/S_RESERVES_IN_MONTH_IMPORTS.R")
source("libraries/data_update/S_RM2RATIO.R")


#Data from IMF
source("libraries/data_update/S_RESERVES.R")
source("libraries/data_update/S_WORLD_RESERVES.R")
source("libraries/data_update/S_RESERVES_P&L.R")

#Data from S&P Ratings
source("libraries/data_update/S_RATINGS.R")

