


#################################################################################
#############   WORLD RESERVES UPDATE SCRIPT ####################################
#################################################################################



# library(IMFData)


databaseID <- "IFS"
startdate <- "1980"
enddate <- ""
checkquery = FALSE
indicator <- c("RAXGFX_USD")
areas1 <- c("XR29","XR43", "JP", "CN", "TW", "XR21")
areas2 <- c("DZ","ID", "IR", "IQ", "KW","LY","NG","OM", "QA","SA","AE","VE")



queryfilter2 <- list(CL_FREA = "Q", CL_AREA_IFS = areas1, CL_INDICATOR_IFS = indicator)
query2 <- CompactDataMethod(databaseID, queryfilter2, startdate, enddate,
                            checkquery, tidy = TRUE)


queryfilter3 <- list(CL_FREA = "Q", CL_AREA_IFS = areas2, CL_INDICATOR_IFS = indicator)
query3 <- CompactDataMethod(databaseID, queryfilter3, startdate, enddate,
                            checkquery, tidy = TRUE)



base2 <- query2[c(1,4,2)] %>%
         set_names(c("date","country.abb","value")) %>%
         mutate(value = as.numeric(value),
                date = str_trim(date))

# str(base2)


base3 <- spread(base2, country.abb, value) %>%
         set_names(c("date", "CN","JP","Taiwan","AdvEco","EmeEco"))

# str(base3)



base5 <- query3[c(1,4,2)] %>%
         set_names(c("date","country.abb","oil.exporters")) %>%
         mutate(oil.exporters = as.numeric(oil.exporters),
                date = str_trim(date))


# str(base5)

oil.exporters <- aggregate(oil.exporters ~ date , base5, sum)


base3 <- merge(base3, oil.exporters, by="date") %>% as.tibble()

base3 <- base3 %>%
         mutate(EM3 = EmeEco - CN - oil.exporters,
                AE2 = AdvEco - JP - Taiwan) %>%
         select(-AdvEco, -EmeEco)

# str(base3)

# base3 %>% gather(area, reserves, -date)  %>%
# ggplot(aes(x=date, y=reserves, color= area))+
#   geom_area()


write_csv2(x    = base3,
           path = "raw_data/world_reserves.csv")

rm(base2, base3, base5,oil.exporters,query2, query3, queryfilter2, queryfilter3, areas1, areas2, checkquery , databaseID, indicator, startdate, enddate)
print("reservas mundiales ok!")
