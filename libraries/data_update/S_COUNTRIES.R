
#################################################################################
#############  COUNTRY LIST IMF   ##############################################
#################################################################################


# library(tidyr)

# 'Metadata_IMF.csv' comes from IMF IFS 'Bulk Download' page, with option 'Include Metadata' selected,
#  all countries, all indicators.


metadata <- read_csv("inputs/Metadata_IFS.csv",
                     col_types = list(col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character(),
                                      col_character()),
                     na = '.')
# str(metadata)

metadata <- subset (metadata, `Metadata Attribute` %in% c("Country Code",
                                                        "Country Full Name",
                                                        "Country ISO 2 Code",
                                                        "Country ISO 3 Code",
                                                        "Country name",
                                                        "Country SDMX Code",
                                                        "Country SDMX Name",
                                                        "Country Short Name"))


metadata <- metadata[c(4,7,8)]

metadata <- spread(metadata, `Metadata Attribute`, `Metadata Value` )

write_csv2(x    = metadata,
           path = "inputs/imfcountriesmetadata.csv",
           na = '.')


