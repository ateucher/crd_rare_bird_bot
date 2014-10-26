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