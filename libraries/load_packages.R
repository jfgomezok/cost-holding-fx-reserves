
############ CARGA DE PAQUETES ################################
###############################################################




if ( !require("pacman") ) install.packages("pacman")
pacman::p_load( lfe, stargazer, tidyverse, tinytex, 
                foreign, ggrepel, knitr, kableExtra, scales,
                wbstats, zoo, IMFData, splines, cowplot,
                gridExtra, gganimate, rvest, lubridate, httr, jsonlite, car)

options(scipen=999)

