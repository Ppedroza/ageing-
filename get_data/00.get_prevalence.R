#data.table
library(data.table)

#locations 
locs <- fread("/ihme/homes/ppedroza/Ageing_USA/data/covs_and_misc/loc_meta_data.csv")
us_locs <- locs[parent_id == 102]

#makes vector with US states location ids
us_loc_ids <- us_locs[['location_id']]

#age_group_ids
#ages <- c(13, 14, 15, 16, 17, 18, 19, 20, 30, 31, 32, 235)
ages <- c(8:12) # ages that I was missing

#year_ids
year_ids <- 1990:2017

# Cause list
# all causes
# pre_causes <- c(954, 321, 351, 352, 354, 355, 356, 361, 362, 365, 379, 381, 382, 383, 384, 385, 390, 391, 498, 970, 938, 
#                 944, 507, 520, 541, 670, 671, 672, 999, 1000, 675, 674, 643, 645, 646, 647, 648, 649, 651, 652, 602, 606, 
#                 614, 837, 615, 838, 616, 839, 618, 685, 941)

pre_causes <- c(321, 352, 354, 355, 356, 361, 362, 365, 379, 381, 382, 383, 384, 385, 390, 391, 498, 970, 938, 
                944, 507, 520, 541, 670, 671, 672, 999, 1000, 675, 674, 643, 645, 646, 647, 648, 649, 651, 652, 602, 606, 
                614, 837, 615, 838, 616, 839, 618, 685, 941)


# 
# I'm not sure I need the next few lines
# source("/ihme/cc_resources/libraries/2017_archive/r/get_cause_metadata.R")
# causes <- as.data.table(get_cause_metadata(gbd_round_id = 5, cause_set_version_id = 12))
# set1 <- get_cause_metadata(gbd_round_id = 5, cause_set_id = 1)
# set2 <- get_cause_metadata(gbd_round_id = 5, cause_set_id = 3)


source("/ihme/cc_resources/libraries/2017_archive/r/get_draws.R")
root <- "/ihme/homes/ppedroza/Ageing_USA/data/raw/prevalence/"


for (pc in pre_causes) {
  pre <- get_draws('cause_id', 
                   pc, 
                   location_id = us_loc_ids, 
                   year_id = year_ids, 
                   source ="como", 
                   gbd_round_id = 5, 
                   sex_id = 3, 
                   metric_id = 3, 
                   measure_id = 5,
                   age_group_id = ages, 
                   num_workers = 5)
  
  write.csv(pre, paste0(root, pc, "_pre.csv"), row.names = FALSE)
}