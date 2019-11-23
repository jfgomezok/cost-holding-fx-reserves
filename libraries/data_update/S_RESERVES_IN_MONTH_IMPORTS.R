
#################################################################################
#######   RESERVES IN MONTH OF IMPORTS UPDATE SCRIPT  ###########################
#################################################################################

# library(wbstats)
# library(ggplot2)

# str(wb_cachelist, max.level = 1)
# new_cache <- wbcache()
# reserves <- wbsearch(pattern = "Total reserves in months of imports")
# head(embi)


# Total reserves comprise holdings of monetary gold, special drawing rights,
# reserves of IMF members held by the IMF, and holdings of foreign exchange
#  under the control of monetary authorities. The gold component of these reserves
# is valued at year-end (December 31) London prices. This item shows reserves
# expressed in terms of the number of months of imports of goods and services
# they could pay for [Reserves/(Imports/12)].



query <- wb(indicator = "FI.RES.TOTL.MO",
                        startdate = "1960",
                        enddate = "2019",
                        POSIXct=TRUE)


RtoM <- query %>%
        select(iso3c, iso2c, value, country, date_ct) %>%
        set_names(c("wbcode3", 'wbcode2',  "value", "country_name", "date"))

#Sandbox:
# 
# RtoM %>% filter(wbcode3 %in% c("MIC", "HIC")) %>%# 
# ggplot(aes(x=date, y=value))+
#   geom_line(aes(colour=wbcode3))+
#   scale_color_manual(labels = c("High Income", "Middle Income"),
#                            values = c("red", "blue"))+
#   guides(color=guide_legend("Group of countries"))+
#   labs(title="Total reserves in months of imports",
#             x="date",
#             y="",
#             caption="Source: The World Bank")+
#   theme_classic()
# 



write_csv2(x    = RtoM,
           path = "raw_data/reserves_to_imports.csv")

rm(query, RtoM)
print("reserves to imports ok!")
