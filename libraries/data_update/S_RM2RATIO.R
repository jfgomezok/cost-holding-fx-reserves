
#################################################################################
#############   RESERVES vs M2 RATIO UPDATE SCRIPT ##############################
#################################################################################


# str(wb_cachelist, max.level = 1)
# new_cache <- wbcache()
# embi <- wbsearch(pattern = "external debt stock")
# head(embi)


query <- wb(indicator = "FM.LBL.BMNY.IR.ZS",
                        startdate = "1970",
                        enddate = "2018",
                        POSIXct=TRUE)

# names(query)
# str(query)

rm2ratio <- query %>%
            select(iso3c, value, country, date_ct) %>%
            set_names(c("wbcode3", "ratio", "country_name_wb", "date"))


# str(rm2ratio)
# class(rm2ratio)


# unique(rm2ratio$country_name_wb)
# 
# countries <- c("ARG","BRA","CHL", "MEX", "TUR", "RUS","CHN", "IND", "ZAF")
# 
# mybase <- rm2ratio %>%
#           filter(wbcode3 %in% countries)
# 
# rm2ratio %>%
#   filter(wbcode3 %in% c("BRA", "ARG")) %>%
#   ggplot(aes(x=date, y=ratio, colour=wbcode3))+
#   geom_line()


write_csv2(x = rm2ratio,
          path = "raw_data/reserves_m2_ratio.csv")

rm(query,  rm2ratio)
print("reserves to M2 ratio OK!")
