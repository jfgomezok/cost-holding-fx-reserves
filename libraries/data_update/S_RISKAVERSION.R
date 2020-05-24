

#################################################################################
#############   RISK AVERSION UPDATE SCRIPT #####################################
#################################################################################


# library(FredR)

if(!exists('api.key')){stop('You should provide a API key')} else {print('API key ok!')}



# Set the api call 
url <- 'https://api.stlouisfed.org/fred/series/'
category <- 'observations?series_id=BAMLH0A0HYM2'
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

bofahy <- JSON %>%
          select(observations.date, observations.value) %>%
          set_names(c('date', 'riskaversion')) %>%
          filter(riskaversion != ".") %>% 
          mutate(date = parse_date(date),
                 riskaversion = as.numeric(riskaversion))


# str(bofahy)

# Chart:
# bofahy %>% filter(date >= ymd('20180101')) %>%
#   ggplot(aes(x=date, y=riskaversion)) + geom_line()

write_csv2(x    = bofahy,
           path = "raw_data/risk.aversion.csv")

rm(bofahy, Request,  Response, JSON,  url, category, file_type, frequency, aggregation_method, path )
print("risk aversion ok!")
