
#################################################################################
#############  LISTADO DE PAISES   ##############################################
#################################################################################


library(tidyr)

# 'Metadata_IMF.csv' comes from IMF IFS 'Bulk Download' page, with option 'Include Metadata' selected,
#  all countries, all indicators.


metadata <- read.csv("Inputs/Metadata_IFS.csv")

metadata <- subset (metadata, Metadata.Attribute %in% c("Country Code",
                                                        "Country Full Name",
                                                        "Country ISO 2 Code",
                                                        "Country ISO 3 Code",
                                                        "Country name",
                                                        "Country SDMX Code",
                                                        "Country SDMX Name",
                                                        "Country Short Name"))


metadata <- metadata[c(4,7,8)]

metadata <- spread(metadata, Metadata.Attribute, Metadata.Value )[c(2:8)]

write.csv2(metadata, file="Inputs/imfcountriesmetadata.csv", row.names=FALSE)


