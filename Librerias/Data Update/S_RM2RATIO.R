
#################################################################################
#############   ACTUALIZACION DE LA RESERVES - M2 RATIO##########################
#################################################################################



library(wbstats)
library(ggplot2)

# 
# str(wb_cachelist, max.level = 1)
# new_cache <- wbcache()
# embi <- wbsearch(pattern = "external debt stock")
# head(embi)


query <- wb(indicator = "FM.LBL.BMNY.IR.ZS",
                        startdate = "1970",
                        enddate = "2018",
                        POSIXct=TRUE)

rm2ratio <- query[c(1,3,7,8)]

colnames(rm2ratio) <- c("wbcode3", "ratio", "country_name_wb", "date")

rm2ratio$date <- as.Date(rm2ratio$date)
rm2ratio$ratio <- as.numeric(rm2ratio$ratio)
# str(rm2ratio)


countries <- c("ARG","BRA","CHL", "MEX", "TUR", "RUS","CHN", "IND", "ZAF")

mybase <- subset(rm2ratio, wbcode3 %in% countries)
# 
# ggplot(mybase, aes(x=date, y=ratio))+
#   geom_line( aes(color = wbcode3))


write.csv2(rm2ratio, file="raw_data/reserves_m2_ratio.csv", row.names = FALSE)
rm(query,  rm2ratio, countries, mybase)
print("reserves to M2 ratio OK!")
