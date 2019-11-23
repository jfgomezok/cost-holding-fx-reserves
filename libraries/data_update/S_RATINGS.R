#################################################################################
######################   S&P RATINGS  ###########################################
#################################################################################


path <- "https://www.capitaliq.com/CIQDotNet/CreditResearch/RenderArticle.aspx?articleId=2190292&SctArtId=469442&from=CM&nsl_code=LIME&sourceObjectId=10935310&sourceRevId=1&fee_ind=N&exp_date=20290407-15:53:53"

url <- read_html(path)

spy_original <- as.data.frame(url %>%
                              html_nodes(xpath = '//*[@id="researchContent"]/table[4]')  %>%
                              html_table())

ratings <- as_tibble(spy_original) %>%
           set_names(c("date", "foreign_currency_rating", "local_currency_rating", "assessment")) %>%
           slice(-1) %>%
           select(date, foreign_currency_rating) %>%
           mutate(country = NA) %>%
           separate(foreign_currency_rating, c("A","B", "C"), sep = "/")


ratings[1, 5] <- ratings[1, 2]

for (i in 1:nrow(ratings)) {
  
  # i<-2
  if ( is.na(ratings[i+1, 4]) == TRUE )
  {ratings[i+1, 5] <- ratings[i+1, 2]}
  else
  {ratings[i+1, 5] <- ratings[i+1-1, 5]}
  
}


ratings <- na.omit(ratings)

# str(ratings)

ratings$date <- parse_date(ratings$date, format = "%b. %d, %Y")

# str(ratings)

 
ratings <- ratings %>% select(date,country,A) %>%
           set_names(c("date", "country", "rating"))



####################################################
#  REPEAT EACH MONTH ------------------------------
####################################################


countries_list <- unique(ratings$country)

new_db <- tribble()

for (i in countries_list){
  
  # i <- "Brazil"
  
  #Nota mental: le  agregue un mes para que me coincida con el excel de trabajo 
  
  #1st Step: take each country
  temp <- ratings %>%
          filter (country == i) %>%
          mutate(date = as.Date(format(date, '%Y-%m-01')) %m+% months(1))
  
  #2nd Step: keep only one rating for each month
  temp <- temp[!duplicated(temp$date),]  

  #3rd Setp: Identification of the  time lapse
  first_date <- as.Date(format(min(temp$date), "%Y-%m-01"))
  last_date <- as.Date(Sys.Date())
  #last_date <- as.Date(format(max(temp$date), "%Y-%m-01"))
  
  #4th Step: create a sequence of date for that country ... 
  seq <- seq.Date(first_date, last_date, by="month")
  
  db_temp <-  as.data.frame(seq) %>%
              mutate(rating = NA,
                     country = i) %>%
              rename(date = "seq")
            
  
  db_temp2 <- merge(db_temp, temp, by=c("date", "country"), all=T) %>% 
              rename(rating_original = rating.y) %>%
              rename(rating_new = rating.x) %>%
              arrange(date)
              
  
  #5th Step: repeat each rating in month with NA
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

RatingMap <- data.frame(
  "rating"=c("AAA","AAA-",  "AA+",  "AA","AA-", "A+",  "A","A-",  "BBB+",  "BBB","BBB-",  "BB+",  "BB","BB-",  "B+",  "B","B-",  "CCC+",  "CCC","CCC-",  "CC+", "CC","CC-",  "C+", " C","C-",  "SD","D","NR"),
  "rating_equiv"=c(29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1)
  )



new_db2 <- merge(new_db, RatingMap, by=c("rating"), all=T)

new_db2 <- na.omit(new_db2)




####################################################
# ---- COUNTRY NAMES -------------------------------
####################################################


spy_equiv <- read_csv2("inputs/spy_country_equiv.csv")

new_db3 <- merge(new_db2, spy_equiv, by="country")


####################################################
# ---- FINAL BASE ----------------------------------
####################################################


ratings_final <- new_db3[,c("date","country","wbcode3","rating_equiv")] %>%
                 rename(rating = "rating_equiv") %>%
                 arrange(country, date)

# str(ratings_final)





# EXPORT ----------------------------------------------------------
write_csv2(x = ratings_final,
           path = "raw_data/ratings_scraper.csv"
           )

rm(spy_equiv, path, db_temp, db_temp2, db_temp3, RatingMap, new_db, new_db2,  new_db3, ratings, ratings_final, spy_original, temp, url, countries_list, first_date, last_date, i, seq)
print("Rating ok!")





