# This file loads data and does basic


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

pre <- read_feather(paste0(root, 'data/intermediate/prevalence.feather'))
pre_1 <- as.data.table(pre)

#### 
pre_2 <- pre_1[year_id == 2017,]



# removing unnecessary columns 
pre_2[, V1 := NULL]
pre_2[, sex_id:=NULL]
pre_2[, measure_id:=NULL]
pre_2[, metric_id:=NULL]
pre_2[, year_id:=NULL]

# removing duplicate rows
pre_17 <- unique(pre_2, by = c('age_group_id', 'cause_id', 'location_id')) # there are some rows that are duplicates


# Location data
cau <- fread(paste0(root, "data/covs_and_misc/cause_meta_data.csv"))
causes <- cau[, .(cause_id, cause_name)]

# Adding causes to preavalence 
pre_17 <- merge(pre_17, causes)

###################
## Cleaning data
###################

# Cleaning age_group_id variable
pre_17[age_group_id==8 , agegrp:=17] ; 
pre_17[age_group_id==9 , agegrp:=22] ; pre_17[age_group_id==10 , agegrp:=27]
pre_17[age_group_id==11 , agegrp:=32] ; pre_17[age_group_id==12 , agegrp:=37]
pre_17[age_group_id==13 , agegrp:=42] ; pre_17[age_group_id==14 , agegrp:=47]
pre_17[age_group_id==15 , agegrp:=52] ; pre_17[age_group_id==16 , agegrp:=57]
pre_17[age_group_id==17 , agegrp:=62] ; pre_17[age_group_id==18 , agegrp:=67]
pre_17[age_group_id==19 , agegrp:=72] ; pre_17[age_group_id==20 , agegrp:=77]
pre_17[age_group_id==30 , agegrp:=82] ; pre_17[age_group_id==31 , agegrp:=87] 
pre_17[age_group_id==32 , agegrp:=92] ; pre_17[age_group_id==235 , agegrp:=100] 

# Removing unnecessary columns
pre_17[, age_group_id:=NULL]
pre_17[, location_id:=NULL]

# Calculating the squared of age
pre_17[,agegrp2:=agegrp^2]

# saving clean data
write_feather(pre_17, 
              paste0(root, 'data/intermediate/00.prev_cleaned.feather'))
