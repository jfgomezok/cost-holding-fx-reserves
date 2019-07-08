
############ CARGA DE PAQUETES ################################
###############################################################




if ( !require("pacman") ) install.packages("pacman")
pacman::p_load( lfe, stargazer, tidyverse, car, tinytex, 
                foreign, ggrepel, knitr, kableExtra, scales,
                wbstats, zoo, FredR, IMFData, splines, cowplot,
                gridExtra, gganimate, rvest, lubridate)


