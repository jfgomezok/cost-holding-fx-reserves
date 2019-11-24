

#################################################################################
#############   US10Y DATA UPDATE SCRIPT ########################################
#################################################################################

# Check api key
if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}


# Set the api call 
url <- 'https://api.stlouisfed.org/fred/series/'
category <- 'observations?series_id=DGS10'
file_type <- 'file_type=json'
frequency = 'frequency=m'
aggregation_method = 'aggregation_method=avg'
path <- paste0(url, category, "&", frequency, '&',aggregation_method,"&", 'api_key=',api.key, "&", file_type)

# Call the api
Request <- GET(url = path)
Response <- content(Request, as = "text", encoding = "UTF-8")

# Parse the JSON content and convert it to a tibble
JSON <- fromJSON(Response, flatten = TRUE) %>%
  data.frame() %>% as_tibble()


US10y.fred <- JSON %>%
  select(observations.date, observations.value) %>%
  set_names(c('date', 'value')) %>%
  mutate(date = parse_date(date),
         value = as.numeric(value))




write_csv2(x = US10y.fred, path = "raw_data/us10y.csv")
rm(fred, US10y.fred  )
print("us10y ok!")