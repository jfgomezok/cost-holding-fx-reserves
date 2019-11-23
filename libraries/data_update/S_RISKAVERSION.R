

#################################################################################
#############   RISK AVERSION UPDATE SCRIPT #####################################
#################################################################################


# library(FredR)

if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}



fred <- FredR(api.key)
bofahy_query <- fred$series.observations(series_id = "BAMLH0A0HYM2", frequency = "m")

bofahy <- bofahy_query %>%
          mutate(value = parse_number(value, na = '.')*100,
                 date  = parse_date(date) ) %>%
          select(date, value) %>%
          set_names(c("date", "riskaversion"))

# str(bofahy)

# Chart:
# bofahy %>% filter(date >= ymd('20180101')) %>%
#   ggplot(aes(x=date, y=riskaversion)) + geom_line()

write_csv2(x    = bofahy,
           path = "raw_data/risk.aversion.csv")

rm(bofahy,  fred, bofahy_query)
print("risk aversion ok!")
