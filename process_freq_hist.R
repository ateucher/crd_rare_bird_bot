library("rebird")

source("fun.R")

freq <- get_freq("counties", "CA-BC-CP", 1990, 2014, 1, 12)

# Get a list of common birds for the current quarter of the month
common_now <- get_common(freq, Sys.Date(), 0.01)

# Get all the bird sightings for the region
crd_birds <- ebirdregion(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE)

# Get the rare birds out of all the sightings and extract their locations
rare_birds <- crd_birds[!crd_birds$comName %in% common_now,]
locs <- unique(rare_birds$locID)

# Get full checklists for those locations
loc_df <- get_full_checklists(locs)

# Extract the rare birds from those locations
rare_birds <- loc_df[!loc_df$comName %in% common_now,]

# Get tagged rare birds
crd_rare <- ebirdnotable(region = "CA-BC-CP", regtype = "subnational2", back = 3, 
                         provisional = TRUE, hotspot = FALSE, simple = FALSE)

crd <- unique(rbind(rare_birds, crd_rare))

