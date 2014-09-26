library("rebird")
library("dplyr")
library("httr")

source("fun.R")

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
