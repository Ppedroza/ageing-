# Clean environmentn 
rm(list=ls())

library(data.table)


###########
## Loading data
###########

inc <- read_feather('/ihme/homes/ppedroza/Ageing_USA/data/intermediate/inc_compiled.feather')
inc<- data.table(inc)
inc[, V1 := 'V1']
inc_17 <- inc[year_id == 2017]
 

# Location data
cau <- fread("/ihme/homes/ppedroza/Ageing_USA/data/covs_and_misc/cause_meta_data.csv")
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
inc_17[,V1:=NULL]; inc_17[,age_group_id:=NULL];
inc_17[,sex_id:=NULL]; inc_17[,year_id:=NULL]; inc_17[,location_id:=NULL];
inc_17[,measure_id:=NULL]; inc_17[, metric_id:=NULL];

# Calculating the squared of age
inc_17[,agegrp2:=agegrp^2]

##############################
# Looking into causes that have too many zeros
##############################

# Flags causes that have zeros in draw_0
cause_no_incid <-inc_17[draw_0==0,.(cause_name)]
unique(cause_no_incid) # This gives me a datatable with the causes that don't have incidence and how many draws don't have it either. 
causes_ni_list <- unique(cause_no_incid$cause_name)

# Evaluation causes that have zeros in draw_0
cause_no_incid[ , ':='( count_c0 = .N ) , by = cause_name ]
# cause_no_incid[, table(count_c0)]






inc_17[draw_0 == 0, ':='(causes_with_zeros_cnt = .N), by = cause_name] 

# Quantifies how many age_group_ids have zeros. 
# I think if there are less than 12 zeros, we can keep this cause
# It's a sign that the decease doesn't exist in one location for any age_group_id
inc_17[!is.na(causes_with_zeros_cnt), ':='(number_of_agi_w_zeros = .N), by = cause_name] 

causes_no_inc <- inc_17[number_of_agi_w_zeros > 13, unique(cause_name)]


inc_17[cause_id == 339 & draw_0 == 0 & location_id == 385,.N, by = .(location_id)]
inc_17[, .N, by = .(location_id, age_group_id)]
length(unique(inc_17$age_group_id))