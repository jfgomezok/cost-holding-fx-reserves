

############################################################################
################## COUNTRIES METADATA FROM WB ##############################
############################################################################


path <- 'http://api.worldbank.org/v2/country?per_page=900&format=json&source=6'

locationRequest <- GET(url = path)
locationResponse <- content(locationRequest, as = "text", encoding = "UTF-8")

# Parse the JSON content and convert it to a data frame.
locationsJSON <- fromJSON(locationResponse, flatten = TRUE) %>%
  data.frame() %>% as.tibble()


class(locationsJSON)


countries <- locationsJSON %>%
             select(id, iso2Code, name) %>%
             set_names(c('wbcode3', 'wbcode2', 'country_name_wb'))

write_csv2(x = countries,
           path = 'raw_data/CountriesWB.csv',
           na = '.')

rm(path, locationRequest, locationResponse,  locationsJSON, countries)
