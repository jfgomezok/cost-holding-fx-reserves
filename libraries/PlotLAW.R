



LAWPlot <- function(country){
  
  
  # country <- "ARG"
  
  df.area <- chart_df_2 %>%
             filter (wbcode3 == country)
  
  
  max.prim.arg <- max(df.area[,c(4:6)],na.rm = TRUE)
  min.prim.arg <- min(df.area[,c(4:6)],na.rm = TRUE)
  max.sec.arg <- max(df.area[,3],na.rm = TRUE)
  min.sec.arg <- min(df.area[,3],na.rm = TRUE)
  f1.arg <- (max.prim.arg - min.prim.arg) / (max.sec.arg  - min.sec.arg)
  df.area$NERadj <- (df.area$NER - max.sec.arg) * f1.arg + max.prim.arg
  
  
  
  chart_df_2_gather <- gather(df.area, Reference, value, 3:7)
  
  
  plot <- chart_df_2_gather %>%  
    ggplot(aes(date, value, group=Reference)) +
    geom_area(data=subset(chart_df_2_gather, Reference != "PNL.total.monthly.acum1" & Reference != "NER" & Reference != "NERadj"),
              aes(fill=Reference),
              position = "stack")+
    geom_point(data=subset(chart_df_2_gather, Reference == "PNL.total.monthly.acum1"),
               aes(color="PNL Total"),
               color='black',
               size=0.8)+
    facet_wrap(~ wbcode3, scales = "free")+
    geom_line(data=subset(chart_df_2_gather, Reference == "NERadj"),
              aes(color="Exchange Rate"),
              color="black")+
    scale_y_continuous("",
                       sec.axis =  sec_axis(~ (.-max.prim.arg) / f1.arg +max.sec.arg ,
                                            name = paste0(country,"/USD") ))+
    scale_x_date("",date_breaks = "2 year",labels = date_format("'%y"))+
    theme(legend.position="none",
          axis.line = element_blank(),
          # axis.ticks = element_blank(),
          axis.text = element_text(size=8),
          axis.title = element_text(size=9))
  
  plot
  
  return(plot)
  
  
}
