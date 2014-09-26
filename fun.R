shorten <- function(url, token) {
  stop_for_status(GET(url))
  
  res <- GET("https://api-ssl.bitly.com/v3/shorten", 
             query = list(access_token=token, longUrl=url))
  
  stop_for_status(res)
  
  con <- content(res)
  
  short_url <- con$data$url
  
  short_url
}