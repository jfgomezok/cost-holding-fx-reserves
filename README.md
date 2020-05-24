
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Cost of Holding Foreign Exchange Reserves

## Overview

Replication files for ‘Cost of Holding Foreign Exchange Reserves’ by
Eduardo Levy Yeyati and Juan Francisco Gomez, CID Faculty Working Paper
Series No. 353, May 2019, Harvard.

Available at:
<https://www.hks.harvard.edu/centers/cid/publications/faculty-working-papers/holding-exchange-reserves>

## Installing this repository:

Git users are welcome to fork this repository or clone it for local use.

Non-Git users will probably find it easier to download the zip file by
clicking on the “Clone or download” button on the right hand side of
this screen, and then clicking “Download ZIP”. Once downloaded, always
start by opening the ‘Rproj’ file (in this case:
cost-holding-fx-reserves.Rproj).

## Required Software:

  - [R](https://cran.r-project.org/)

  - [Rstudio](https://www.rstudio.com/products/rstudio/download/)

  - Api key of the Federal Reserve Bank of San Louis, available at:
    <https://research.stlouisfed.org/docs/api/api_key.html>. Once in
    hand, write it in line 6 of `sample_stlouis_api_key.R` and then
    change its name to `stlouis_api_key.R`.

## Files structure

1.  `data_generator.R` will install and load the required packages,
    download the data from public warehouses (i.e IMF, WB, St.Louis FED,
    S\&P), save them in folder ‘raw\_data’, and lastly build two panels
    saved in folder ‘Outputs’:
    
      - self\_insurance\_db.csv is the section 3 data base (‘DB’).
      - law\_db.csv is the section 4 DB.

2.  `Exploratory_Data_Analysis.Rmd` explores the data through tables and
    plots.

3.  `Self_Insurance_Regressions.Rmd` loads the section 3 DB and performs
    the regressions.

4.  `Law_Model_analysis.Rmd` loads the section 4 DB and perform the
    analytics.

## Contributing

Comments are very welcome, usual disclaimers apply. This package is
still under development, so play nice.

### Author/Maintainer

  - [Juan Francisco Gomez](https://github.com/jfgomezok)
