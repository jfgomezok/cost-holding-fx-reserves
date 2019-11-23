

#################################################################################
#############   LIBOR UPDATE SCRIPT #############################################
#################################################################################


if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}


fred <- FredR(api.key)
libor.query <- fred$series.observations(series_id = "GBP3MTD156N", frequency="m")
# str(libor.fred)

libor <-  libor.query %>%
          mutate(value = parse_number(value),
                 date  = parse_date(date) ) %>%
          select(date, value) %>%
          set_names(c("date", "libor.TNA"))


write_csv2(x    = libor,
           path = "raw_data/libor.csv")

rm(fred, libor.query, libor)
print("libor OK!")
