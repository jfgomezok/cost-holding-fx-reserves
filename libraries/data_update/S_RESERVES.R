

#################################################################################
#############   RESERVES UPDATE SCRIPT ##########################################
#################################################################################


# library(IMFData)


# IFS.available.codes <- DataStructureMethod("IFS")
# All_Areas <- IFS.available.codes[[2]]
# All_Indicators <- IFS.available.codes[[3]]

databaseID <- "IFS"
startdate <- "1980"
enddate <- ""
checkquery = FALSE
indicator <- c("RAFA_MV_USD")
areas <- ""

queryfilter <- list(CL_FREA = "M", CL_AREA_IFS = areas, CL_INDICATOR_IFS = indicator)

reserves.query <- CompactDataMethod(databaseID, queryfilter, startdate, enddate,
                                    checkquery,verbose = FALSE, tidy = TRUE)

reserves.ifs <- reserves.query %>%
  select(1,4,2) %>%
  set_names(c("date","wbcode2","reserves")) %>%
  mutate(reserves = parse_number(reserves) / 1000,   # in billions
         date = parse_date(paste0(date, '-01')))

# str(reserves.ifs)

countries.wb <- read_csv2('raw_data/CountriesWB.csv', na = '.')[,c(1,2)]

reserves.ifs <- merge (reserves.ifs, countries.wb, by = "wbcode2")


reserves.ifs <- reserves.ifs[,c('wbcode3','date','reserves')]
# str(reserves.ifs)

write_csv2(x    = reserves.ifs,
           path = "raw_data/reserves.ifs.csv")


rm(reserves.ifs, countries.wb, queryfilter,reserves.query,databaseID, startdate, enddate,checkquery, indicator, areas )
print("reserves ok!")
