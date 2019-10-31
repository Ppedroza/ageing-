#data.table
library(data.table)

#locations 
locs <- fread("/ihme/homes/ppedroza/Ageing_USA/data/covs_and_misc/loc_meta_data.csv")
us_locs <- locs[parent_id == 102]

#makes vector with US states location ids
us_loc_ids <- us_locs[['location_id']]

#age_group_ids
#ages <- c(13, 14, 15, 16, 17, 18, 19, 20, 30, 31, 32, 235)
ages <- (8:12)

#year_ids
year_ids <- 1990:2017


#incidence draws
# source("/ihme/cc_resources/libraries/2017_archive/r/get_cause_metadata.R")
# inc_causes <- as.data.table(get_cause_metadata(cause_set_version_id = 286))
# 
# inc_causes <- inc_causes[level >2]
# ic <- inc_causes[most_detailed ==1, .(cause_id, cause_name)]
# ic_ids <- ic[['cause_id']]
# length(ic_ids)


#incidence

#probably have to write a for loop to pull data from the db one cause a the time and joined them at the end

#incidence draws

source("/ihme/cc_resources/libraries/2017_archive/r/get_draws.R")

root <- "/ihme/homes/ppedroza/Ageing_USA/data/raw/incidence/"



loc_dt <- get_location_metadata(location_set_id = 35)
us_locs <- loc_dt[parent_id == 102]

#makes vector with US states location ids
us_loc_ids <- us_locs[['location_id']]
ages <- 8:12


#ic_ids <- ic_ids[-c(1:9)] #This is how I remove the items that I already removed staff from. 
for (ic in cause_ids) {
inc <- get_draws('cause_id', 
                   ic, 
                   location_id = us_loc_ids, 
                   year_id = year_ids, 
                   source ="como", 
                   gbd_round_id = 5, 
                   sex_id = 3, 
                   metric_id = 3, 
                   measure_id = 6,
                   age_group_id = ages, 
                   num_workers = 5)

write.csv(inc, paste0(root, ic, ".csv"))
}
