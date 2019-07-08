#################################################################################
######################   S&P RATINGS  ###########################################
#################################################################################


url <- read_html("https://www.capitaliq.com/CIQDotNet/CreditResearch/RenderArticle.aspx?articleId=2190292&SctArtId=469442&from=CM&nsl_code=LIME&sourceObjectId=10935310&sourceRevId=1&fee_ind=N&exp_date=20290407-15:53:53")

spy_original <- as.data.frame(url %>%
                              html_nodes(xpath = '//*[@id="researchContent"]/table[4]')  %>%
                              html_table())

ratings <- spy_original

colnames(ratings) <- c("date", "foreign_currency_rating", "local_currency_rating", "assessment")
ratings <- ratings[-1,c(1,2)]


ratings["country"] <- NA


aux1 <- as.data.frame(unique(ratings$date))
colnames(aux1) <- "test"

 
ratings["country"] <- NA
ratings <- ratings %>% separate(foreign_currency_rating, c("A","B", "C"), sep = "/")

ratings[1, 5] <- ratings[1, 2]

for (i in 1:nrow(ratings)) {
  
  # i<-2
  if ( is.na(ratings[i+1, 4]) == TRUE )
  {ratings[i+1, 5] <- ratings[i+1, 2]}
  else
  {ratings[i+1, 5] <- ratings[i+1-1, 5]}
  
}


ratings <- na.omit(ratings)

ratings$date <- gsub("Aug", "Ago", ratings$date)
ratings$date <- gsub("Dec", "Dic", ratings$date)
ratings$date <- gsub("Apr", "Abr", ratings$date)
ratings$date <- gsub("Jan", "Ene", ratings$date)


ratings$date <- as.Date(ratings$date, "%b %d, %Y")


ratings <- ratings[,c(1,5,2)]
colnames(ratings) <- c("date", "country", "rating")


####################################################
# EXPANSION DE MESES ------------------------------
####################################################


countries_list <- unique(ratings$country)

new_db <- data.frame()

for (i in countries_list){
  
  # i <- "Brazil"
  

  #Nota mental: le  agregue un mes para que me coincida con el excel de trabajo 
  temp <- ratings %>%
    filter (country == i) %>%
    mutate(date = as.Date(format(date, '%Y-%m-01')) %m+% months(1))
  
  temp <- temp[!duplicated(temp$date),]  #Saco los duplicados
                                          # (hay meses que tienen dos cambios de calificacion,
                                          #   y yo necesito uno solo)

  # str(temp)
  first_date <- as.Date(format(min(temp$date), "%Y-%m-01"))
  last_date <- as.Date(Sys.Date())
  #last_date <- as.Date(format(max(temp$date), "%Y-%m-01"))
    
  seq <- seq.Date(first_date, last_date, by="month")
  
  db_temp <- as.data.frame(seq) %>%
    mutate(rating = NA,
           country = i) %>%
    rename(date = "seq")
  
  
  db_temp2 <- merge(db_temp, temp, by=c("date", "country"), all=T) %>% 
    rename(rating_original = rating.y) %>%
    rename(rating_new = rating.x) %>%
    arrange(date)
    
  
  for (i in 1:nrow(db_temp2)){
    # i<- 1
    db_temp2[i,3] <- ifelse(is.na(db_temp2[i,4]) ==F,  db_temp2[i,4], db_temp2[i-1,3])
   }
  
  db_temp3 <- db_temp2[1:3]
  colnames(db_temp3)<- c("date", "country", "rating") 
  
  new_db <- rbind(new_db, db_temp3)
  
}






####################################################
# ---- RATING MAPPING ---- -------------------------
####################################################


# unique(new_db$rating)

equivalencias <- data.frame("rating"=c("AAA","AAA-",  "AA+",  "AA","AA-", "A+",  "A","A-",  "BBB+",  "BBB","BBB-",  "BB+",  "BB","BB-",  "B+",  "B","B-",  "CCC+",  "CCC","CCC-",  "CC+", "CC","CC-",  "C+", " C","C-",  "SD","D","NR"),
           "rating_equiv"=c(29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1))



new_db2 <- merge(new_db, equivalencias, by=c("rating"), all=T)

new_db2 <- na.omit(new_db2)




####################################################
# ---- EQUIVALENCIAS DE PAISES----------------------
####################################################


spy_equiv <- read.csv2("inputs/spy_country_equiv.csv")

new_db3 <- merge(new_db2, spy_equiv, by="country")


####################################################
# ---- FINAL BASE ----------------------------------
####################################################


ratings_final <- new_db3[,c("date","country","wbcode3","rating_equiv")] %>%
  rename(ratings = "rating_equiv") %>%
  arrange(country) %>%
  arrange(date)

# str(ratings_final)





# EXPORT ----------------------------------------------------------
write.csv2(ratings_final, file="raw_data/ratings_scraper.csv", row.names = FALSE)
rm(spy_equiv, aux1, db_temp, db_temp2, db_temp3, equivalencias, new_db, new_db2,  ratings, ratings_final, spy_original, temp, url, countries_list, first_date, last_date, i, seq)
print("reservas ok!")





