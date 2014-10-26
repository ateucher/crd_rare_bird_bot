library("lubridate")
library("tidyr")
library("rebird")

source("fun.R")

freq <- get_freq("counties", "CA-BC-CP", 1990, 2014, 1, 12)

# freq <- separate(freq, mo_qt, c("month", "month_qt"), "-")
# freq$month_qt <- as.integer(freq$month_qt)

curr_month_qt <- get_month_qt(Sys.Date())

common_now <- freq$Species[freq$mo_qt == curr_month_qt & 
                                  (freq$Freq > 0.03 | 
                                  grepl("sp\\.$", freq$Species))]

crd_birds <- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE, simple = FALSE)

# crd_birds$month_qt <- sapply(as.Date(crd_birds$obsDt), get_month_qt)

rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]

