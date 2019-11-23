

#################################################################################
#############   US TERM PREMIUM UPDATE SCRIPT ###################################
#################################################################################

if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}



fred <- FredR(api.key)
UStp_query <- fred$series.observations(series_id = "T5YFF", frequency="m")
# str(US_tp)

US_tp <-  UStp_query %>%
          mutate(value = parse_number(value),
                 date  = parse_date(date) ) %>%
          select(date, value) %>%
          set_names(c("date", "US_TP"))

# str(US_tp)

# Chart:
# US_tp %>%
#   ggplot(aes(x=date, y=US_TP)) +
#   geom_line() +
#   geom_line(aes(y=0))



write_csv2(x    = US_tp,
           path = "raw_data/US_tp.csv")

rm(fred, UStp_query, US_tp)
print("US term premium OK!")
