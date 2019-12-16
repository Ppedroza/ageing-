


# Clean environmentn 
rm(list=ls())
library(feather)
library(data.table)


# Set directories 
if (Sys.info()["sysname"] =="Linux") {
    root <-"/ihme/homes/ppedroza/Ageing_USA/"
} else {
    root <-"H:/Ageing_USA/"
}



###########
## Loading data
###########
start_time<-Sys.time()
inc <- read_feather(paste0(root, 'data/intermediate/inc_2017_compiled.feather'))


inc_1 <- as.data.table(inc)

end_time<-Sys.time()
end_time-start_time 

# removing unnecessary columns 
inc_1[, V1 := NULL]
inc_1[, sex_id:=NULL]
inc_1[, measure_id:=NULL]
inc_1[, metric_id:=NULL]
inc_1[, year_id:=NULL]

# removing duplicate rows
inc_17 <- unique(inc_1, by = c('age_group_id', 'cause_id', 'location_id')) # there are some rows that are duplicates


# Location data
cau <- fread(paste0(root, "data/covs_and_misc/cause_meta_data.csv"))
causes <- cau[, .(cause_id, cause_name)]

# Adding causes to incidence 
inc_17 <- merge(inc_17, causes)

###################
## Cleaning data
###################

# Cleaning age_group_id variable
inc_17[age_group_id==8 , agegrp:=17] ; 
inc_17[age_group_id==9 , agegrp:=22] ; inc_17[age_group_id==10 , agegrp:=27]
inc_17[age_group_id==11 , agegrp:=32] ; inc_17[age_group_id==12 , agegrp:=37]
inc_17[age_group_id==13 , agegrp:=42] ; inc_17[age_group_id==14 , agegrp:=47]
inc_17[age_group_id==15 , agegrp:=52] ; inc_17[age_group_id==16 , agegrp:=57]
inc_17[age_group_id==17 , agegrp:=62] ; inc_17[age_group_id==18 , agegrp:=67]
inc_17[age_group_id==19 , agegrp:=72] ; inc_17[age_group_id==20 , agegrp:=77]
inc_17[age_group_id==30 , agegrp:=82] ; inc_17[age_group_id==31 , agegrp:=87] 
inc_17[age_group_id==32 , agegrp:=92] ; inc_17[age_group_id==235 , agegrp:=100] 

# Removing unnecessary columns
inc_17[, age_group_id:=NULL]
inc_17[, location_id:=NULL]

# Calculating the squared of age
inc_17[,agegrp2:=agegrp^2]

# saving clean data
write_feather(inc_17, 
              paste0(root, 'data/intermediate/00.inc_cleaned.feather'))
