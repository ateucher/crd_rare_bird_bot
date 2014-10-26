library("httr")
library("tidyr")

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
  names(freq) <- c("Species", sapply(month.name, paste ,1:4, sep="-"))
  freq_long <- gather(freq, "mo_qt", "Freq", 2:length(freq), convert = TRUE)
  freq_long
}