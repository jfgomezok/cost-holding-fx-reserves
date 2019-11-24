

#################################################################################
#############   US TERM PREMIUM UPDATE SCRIPT ###################################
#################################################################################

if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}


# Set the api call 
url <- 'https://api.stlouisfed.org/fred/series/'
category <- 'observations?series_id=T5YFF'
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


US_tp <- JSON %>%
  select(observations.date, observations.value) %>%
  set_names(c('date', 'US_TP')) %>%
  mutate(date = parse_date(date),
         US_TP = as.numeric(US_TP))


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
