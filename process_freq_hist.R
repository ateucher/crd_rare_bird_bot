library("lubridate")
library("tidyr")

download.file("http://ebird.org/ebird/canada/BarChart?cmd=getChart&displayType=download&getLocations=counties&counties=CA-BC-CP&bYear=1900&eYear=2014&bMonth=1&eMonth=12&reportType=location&parentState=CA-BC", 
              destfile = "crd_hist_freq.tsv")

freq <- read.delim("crd_hist_freq.tsv", skip = 12, stringsAsFactors = FALSE)[-1,-50]
freq_names <- c("Species", sapply(month.name, paste ,1:4, sep="-"))
names(freq) <- freq_names

freq_long <- gather(freq, "mo_qt", "Freq", 2:length(freq), convert = TRUE)
freq_long <- separate(freq_long, mo_qt, c("month", "month_qt"), "-")
freq_long$month_qt <- as.integer(freq_long$month_qt)

crd_birds<- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
            provisional = TRUE, hotspot = FALSE, simple = FALSE)
