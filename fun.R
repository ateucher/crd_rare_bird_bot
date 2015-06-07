library("httr")
library("tidyr")
library("lubridate")
library("dplyr")
options("httr_oauth_cache" = TRUE)

shorten <- function(url, token) {
  stop_for_status(GET(url))
  
  res <- GET("https://api-ssl.bitly.com/v3/shorten", 
             query = list(access_token=token, longUrl=url))
  
  stop_for_status(res)
  
  con <- content(res)
  
  short_url <- con$data$url
  
  short_url
}

get_month_qt <- function(date) {
  month <- months(date)
  day <- lubridate::day(date)
  dys <- lubridate::days_in_month(date)
  bins <- seq(from = 1, to = dys, length = 5)
  qt <- cut(day, bins, labels = 1:4, include.lowest = TRUE)
  paste(month, as.integer(qt), sep = "-")
}

get_freq <- function(loctype, loc, startyear, endyear, startmonth, endmonth) {
  args <- list(cmd = "getChart", displayType = "download", getLocations = loctype, 
               counties = loc, bYear = startyear, eYear = endyear, 
               bMonth = startmonth, eMonth = endmonth)
  
  url <- "http://ebird.org/ebird/canada/BarChart"
  ret <- GET(url, query = args)
  stop_for_status(ret)
  asChar <- readBin(ret$content, "character")
  freq <- read.delim(text = asChar, skip = 12, 
                     stringsAsFactors = FALSE)[-1,-50]
  names(freq) <- c("Species", vapply(month.name, paste, FUN.VALUE = character(4), 
                                     1:4, sep="-"))
  freq_long <- tidyr::gather(freq, "mo_qt", "Freq", 2:length(freq), 
                             convert = TRUE)
  freq_long
}

get_common <- function(freqs, date, prop) {
  ## This also removes spuhs and sp1/sp2 birds (eg. Barrows/Common Goldeneye)
  stopifnot(is.numeric(prop), is.data.frame(freqs), is.Date(date))
  
  qt <- get_month_qt(date)
  
  common_spp <- freq$Species[freq$mo_qt == qt & 
                 (freq$Freq > prop | 
                    grepl("sp\\.$|/", freq$Species))]
}

get_full_checklists <- function(locations){
  
  n_locs <- length(locations)
  cuts <- seq(1, n_locs, by = 10)
  if (max(cuts) < n_locs) cuts <- c(cuts, n_locs)
  
  locs <- lapply(seq_along(cuts), function(i) {
    if (i == length(cuts)) {
      ids <- locations[n_locs]
    } else {
      ids <- locations[cuts[i]:(cuts[i+1]-1)]
    }
    ebirdloc(ids, back = 3, provisional = TRUE, sleep = 2, simple = FALSE)
  })
  dplyr::bind_rows(locs)
}

make_tweets <- function(bird_df, bitly_token) {
  bird_df <- mutate(bird_df, 
                    url = paste0("http://ebird.org/ebird/view/checklist?subID=", 
                                 subID), 
                    short_url = vapply(url, shorten, FUN.VALUE = character(1), 
                                       token = bitly_token, USE.NAMES = FALSE))
  bird_df <- arrange(bird_df, obsDt)
  bird_df$conf <- with(bird_df, 
                       ifelse(obsReviewed & obsValid, " (CONFIRMED). ", 
                              ifelse(!obsReviewed & !obsValid, " (UNCONFIRMED). ",
                                     ifelse(obsReviewed & !obsValid, "OMIT", # Shouldn't go here
                                     ". "))))
  bird_df <- bird_df[bird_df$conf != "OMIT", ]
  
  bird_df$locName[bird_df$locationPrivate] <- "a private location"
  
  tweets <- with(bird_df, paste0(howMany, " ", comName, " on ", obsDt, " at ", 
                                 locName, conf, short_url))
  tweets
}

