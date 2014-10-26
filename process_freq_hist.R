library("lubridate")
library("tidyr")
library("rebird")
library("httr")

GET("http://ebird.org/ebird/canada/BarChart?cmd=getChart&displayType=download&getLocations=counties&counties=CA-BC-CP&bYear=1900&eYear=2014&bMonth=1&eMonth=12&reportType=location&parentState=CA-BC", 
    write_disk("crd_hist_freq.tsv"))

freq <- read.delim("crd_hist_freq.tsv", skip = 12, stringsAsFactors = FALSE)[-1,-50]
freq_names <- c("Species", sapply(month.name, paste ,1:4, sep="-"))
names(freq) <- freq_names

freq_long <- gather(freq, "mo_qt", "Freq", 2:length(freq), convert = TRUE)
# freq_long <- separate(freq_long, mo_qt, c("month", "month_qt"), "-")
# freq_long$month_qt <- as.integer(freq_long$month_qt)

curr_month_qt <- get_month_qt(Sys.Date())

common_now <- freq_long$Species[freq_long$mo_qt == curr_month_qt & 
                                  (freq_long$Freq > 0.03 | 
                                  grepl("sp\\.$", freq_long$Species))]

crd_birds <- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE, simple = FALSE)

# crd_birds$month_qt <- sapply(as.Date(crd_birds$obsDt), get_month_qt)

rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]

