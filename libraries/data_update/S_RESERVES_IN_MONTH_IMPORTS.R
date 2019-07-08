
#################################################################################
#######   ACTUALIZACION DE LA RESERVES IN MONTH OF IMPORTS  #####################
#################################################################################

library(wbstats)
library(ggplot2)

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

base <- query[c(1,3,7,8)]

base.groups <- subset(base,   iso3c=="MIC" | iso3c=="HIC" )
                             
# 
# 
# ggplot(base.groups, aes(x=date_ct, y=value))+
#   geom_line(aes(colour=iso3c))+
#   scale_color_manual(labels = c("High Income", "Middle Income"),
#                            values = c("red", "blue"))+
#   guides(color=guide_legend("Group of countries"))+
#   labs(title="Total reserves in months of imports",
#             x="date",
#             y="",
#             caption="Source: The World Bank")+
#   theme_classic()




write.csv2(base.groups, file="raw_data/reserves_to_imports.csv", row.names = FALSE)
rm(base, base.groups,  query)
print("reserves to imports ok!")
