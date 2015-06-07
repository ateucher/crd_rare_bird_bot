library("rebird")
library("dplyr")
library("httr")
library("twitteR")
library("methods") # Required for use with RScript
options("httr_oauth_cache" = TRUE)

# need full path for use in shell script
source("/Users/ateucher/dev/crd_rare_bird_bot/keys.R")
source("/Users/ateucher/dev/crd_rare_bird_bot/fun.R")

## Use process_freq_hist here instead of this call:
freq <- get_freq("counties", "CA-BC-CP", 1990, 2014, 1, 12)

# Get a list of common birds for the current quarter of the month
common_now <- get_common(freq, Sys.Date(), 0.01)

# Get all the bird sightings for the region
crd_birds <- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE)

# Get the rare birds out of all the sightings and extract their locations
rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]
locs <- unique(rare_birds$locID)

# Get full checklists for those locations
loc_df <- get_full_checklists(locs)

# Extract the rare birds from those locations
rare_birds <- loc_df[!loc_df$comName %in% common_now,]

# Get tagged rare birds
crd_rare <- ebirdnotable(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE, simple = FALSE)

crd <- unique(rbind(rare_birds, crd_rare))
 
if (nrow(crd) > 0) {

  tweets <- make_tweets(crd, BitlyToken)
  
  ## Don't duplicate
  if (file.exists("/Users/ateucher/dev/crd_rare_bird_bot/old_tweets.rda")) {
    load("/Users/ateucher/dev/crd_rare_bird_bot/old_tweets.rda")
    tweets  <- setdiff(tweets, old_tweets)
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
