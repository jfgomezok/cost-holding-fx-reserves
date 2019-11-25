

#################################################################################
#############   LIBOR UPDATE SCRIPT #############################################
#################################################################################


if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}


# Set the api call 
url <- 'https://api.stlouisfed.org/fred/series/'
category <- 'observations?series_id=GBP3MTD156N'
file_type <- 'file_type=json'
frequency = 'frequency=m'
aggregation_method = 'aggregation_method=avg'
path <- paste0(url, category, "&", 'api_key=',api.key, "&", file_type , "&", frequency)

# Call the api
Request <- GET(url = path)
Response <- content(Request, as = "text", encoding = "UTF-8")

# Parse the JSON content and convert it to a tibble
JSON <- fromJSON(Response, flatten = TRUE) %>%
  data.frame() %>% as_tibble()

libor <- JSON %>%
  select(observations.date, observations.value) %>%
  set_names(c('date', 'libor.TNA')) %>%
  mutate(date = parse_date(date),
         libor.TNA = as.numeric(libor.TNA))



write_csv2(x    = libor,
           path = "raw_data/libor.csv")

rm(libor, url, JSON, Request, Response, category, file_type, frequency, aggregation_method, path )
print("libor OK!")
