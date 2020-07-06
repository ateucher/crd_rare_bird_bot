library("rebird")
library("dplyr")
library("httr")
library("rtweet")
library("methods") # Required for use with RScript
options("httr_oauth_cache" = TRUE)

homedir <- Sys.getenv("HOME")

# need full path for use in shell script
source(file.path(homedir, "github/crd_rare_bird_bot/fun.R"))

last_year <- as.integer(format(Sys.Date(), "%Y")) - 1

freq <- ebirdfreq("counties", "CA-BC-CP", 1990, last_year, 1, 12)

# Get a list of common birds for the current quarter of the month
# 2020-07-06 Add AMCR to common birds (low historical rates) due to recent
# lump with NOCR
common_now <- c(get_common(freq, Sys.Date(), 0.01), "American Crow")

# Get all the bird sightings for the region
crd_birds <- ebirdregion(loc = "CA-BC-CP", back = 3, 
                         provisional = TRUE, hotspot = FALSE)

# Get the rare birds out of all the sightings and extract their locations
rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]
locs <- unique(rare_birds$locId)

# Get full checklists for those locations
loc_df <- get_full_checklists(locs)

# Extract the rare birds from those locations
rare_birds <- loc_df[!loc_df$comName %in% common_now,]
# rare_birds$note <- "Note: Flagged as rare due to low historical frequencies of observation during this week of the year."

# Get tagged rare birds
crd_rare <- ebirdnotable(region = "CA-BC-CP", back = 3, 
                         provisional = TRUE, hotspot = FALSE, simple = FALSE)
# crd_rare$note <- "Note: Flagged as rare by eBird"

crd <- unique(rbind(rare_birds, crd_rare[, names(rare_birds)]))
 
if (nrow(crd) > 0) {

  tweets <- make_tweets(crd, bitly_token = Sys.getenv("BITLY_TOKEN"))
  
  ## Don't duplicate
  old_tweets_rda <- file.path(homedir, "github/crd_rare_bird_bot/old_tweets.rda")
  if (file.exists(old_tweets_rda)) {
    load(old_tweets_rda)
    tweets  <- setdiff(tweets, old_tweets)
    old_tweets <- c(old_tweets, tweets)
  } else {
    old_tweets <- tweets
  }
  
  ## Twitter
  
  lapply(tweets, function(x) {
    Sys.sleep(3)
    r <- post_tweet(x)
    cat("[", format(Sys.time()), "]", x, "\n",  
        file = file.path(homedir, "cron-jobs", "ebird-log.txt"), 
        append = TRUE)
  })
  
  save(old_tweets, file = file.path(homedir, "github/crd_rare_bird_bot/old_tweets.rda"))
  
}

n <- if (exists("tweets")) length(tweets) else 0L
cat("[", format(Sys.time()), "] Successfully tweeted", n, "tweets\n\n", 
    file = file.path(homedir, "cron-jobs", "ebird-log.txt"), 
    append = TRUE)

