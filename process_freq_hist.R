library("lubridate")
library("rebird")

source("fun.R")

freq <- get_freq("counties", "CA-BC-CP", 1990, 2014, 1, 12)

curr_month_qt <- get_month_qt(Sys.Date())

# Get a list of common birds for the current quarter of the month
common_now <- freq$Species[freq$mo_qt == curr_month_qt & 
                                  (freq$Freq > 0.03 | 
                                  grepl("sp\\.$", freq$Species))]

# Get all the bird sightings for the region
crd_birds <- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE)

# Get the rare birds out of all the sightings and extract their locations
rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]
locs <- unique(rare_birds$locID)

# Get full checklists for those locations, cutting up list of locations into 
# chunks of 10
loc_df <- data.frame()
cuts <- seq(1, length(locs), by = 10)
for (i in 1:length(cuts)) {
  if (i == length(cuts)) {
    ids <- locs[cuts[i]:length(locs)]
  } else {
    ids <- locs[cuts[i]:(cuts[i + 1]-1)]
  }
  loc_df <- rbind(loc_df, ebirdloc(ids, back = 3, provisional = TRUE, sleep = 2, 
                                   simple = FALSE))
}

# Extract the rare birds from those locations
rare_birds <- loc_df[!loc_df$comName %in% common_now,]

