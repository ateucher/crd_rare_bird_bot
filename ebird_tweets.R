library("rebird")
library("dplyr")
library("httr")
library("twitteR")

source("keys.R")
source("fun.R")

crd <- ebirdnotable(region = "CA-BC-CP", regtype = "subnational2", back = 1, 
                    provisional = TRUE, hotspot = FALSE, simple = FALSE)

if (nrow(crd) > 0) {
  crd <- crd %>%
    mutate(url = paste0("http://ebird.org/ebird/view/checklist?subID=", subID), 
           short_url = sapply(url, shorten, token = BitlyToken, 
                              USE.NAMES = FALSE)) 
  
  tweets <- with(crd, paste0(howMany, " ", comName, " on ", obsDt, " at ", locName,  
                             ifelse(!obsReviewed, " (provisional). ", ". "), 
                             short_url))
  
  ## Don't duplicate
  load("old_tweets.rda")
  tweets  <- tweets[!tweets %in% old_tweets]
  
  # Twitter
  
  setup_twitter_oauth(crd_tw_api_key, crd_tw_api_key_secret, crd_tw_access_token, 
                      crd_tw_access_token_secret)
  
  lapply(tweets, tweet)
  
  old_tweets <- c(old_tweets, tweets)
  
  save(old_tweets, file = "old_tweets.rda")
  
}