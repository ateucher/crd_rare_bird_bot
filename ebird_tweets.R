library("rebird")
library("dplyr")
library("httr")
library("twitteR")
library("methods") # Required for use with RScript

# need full path for use in shell script
source("/Users/ateucher/dev/crd_rare_bird_bot/keys.R")
source("/Users/ateucher/dev/crd_rare_bird_bot/fun.R")

## Use process_freq_hist here instead of this call:
crd <- ebirdnotable(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                    provisional = TRUE, hotspot = FALSE, simple = FALSE)
 
if (nrow(crd) > 0) {
  tweets <- make_tweets(crd, BitlyToken)
  
  ## Don't duplicate
  if (file.exists("/Users/ateucher/dev/crd_rare_bird_bot/old_tweets.rda")) {
    load("/Users/ateucher/dev/crd_rare_bird_bot/old_tweets.rda")
    tweets  <- tweets[!tweets %in% old_tweets]
    old_tweets <- c(old_tweets, tweets)
  } else {
    old_tweets <- tweets
  }
  
  ## Twitter
  
  setup_twitter_oauth(crd_tw_api_key, crd_tw_api_key_secret, crd_tw_access_token, 
                      crd_tw_access_token_secret)
  
  lapply(tweets, tweet)
  
  save(old_tweets, file = "/Users/ateucher/dev/crd_rare_bird_bot/old_tweets.rda")
  
}
