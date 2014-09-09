library("rebird")
library("dplyr")
library("httr")

shorten <- function(url, token) {
  stop_for_status(GET(url))
  
  res <- GET("https://api-ssl.bitly.com/v3/shorten", 
             query = list(access_token=token, longUrl=url))
  
  stop_for_status(res)
  
  con <- content(res)
  
  short_url <- con$data$url
  
  short_url
}

crd <- ebirdnotable(region = "CA-BC-CP", regtype = "subnational2", back = 2, 
                    provisional = TRUE, hotspot = FALSE, simple = FALSE)

crd <- crd %>%
  mutate(url = paste0("http://ebird.org/ebird/view/checklist?subID=", subID), 
         short_url = sapply(url, shorten, token = BitlyToken, 
                            USE.NAMES = FALSE), 
         tweet = paste(howMany, comName, "at", locName, "on", obsDt, 
                       ifelse(!obsReviewed, "(provisional).", "."), 
                       short_url))

nchar(crd$tweet)
