##########################################
# select only data from less than 80 years old
# What causes have zeros and how many?
# subset to causes that don't have zeros
# run regressions
#########################################

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

inc <- read_feather(paste0(root, 'data/intermediate/00.inc_cleaned.feather'))
inc_1 <- as.data.table(inc)

## 
# Subseting to less than 80
##
incid_no80 <- inc_1[agegrp<82, ]

# listing causes that have zeros in draw 0
cause_no_incid<-incid_no80[draw_0==0,.(cause_name)]
cause_no_incid[ , ':='( count = .N ) , by = cause_name ]
cause_no_incid[, table(count)]
cause_no_incid <- unique(cause_no_incid)

# make a list causes that have zeros
causes_with_zeros <-cause_no_incid[count>13,unique(cause_name)] 

# there are 51 causes that have zeros for incidence. The smallest count of zeros is 13. 
# most of these causes have more than 100 zeros some have more than 600

##
# Selecting causes that don't have zeros
##

global_incid_no80 <- incid_no80[!cause_name %in% c(causes_with_zeros)]
global_incid_no80[,unique(cause_name)] # 153 causes

# Making dataset to store results

causes_inc_no80 <- global_incid_no80[,unique(cause_name)] # 153
UR_incid_no80 <- data.table(cause_name=rep(causes_inc_no80,each=1000),draw=c(0:999))
draws<-c(0:999)

##
# Runs regression
##

# no 80+ 
start_time<-Sys.time()
for (x in causes_inc_no80){
  dat<-data.frame(subset(global_incid_no80, cause_name==x))
  dat$cause_id <- NULL
  for (i in draws){
    UR_incid_no80[cause_name==x & draw==i,coef_age1:=summary(lm(dat[,i+1]~dat$agegrp))$coefficients[2,1]]
    UR_incid_no80[cause_name==x & draw==i,pval_age1:=summary(lm(dat[,i+1]~dat$agegrp))$coefficients[2,4]]
    UR_incid_no80[cause_name==x & draw==i,coef_age2:=summary(lm(dat[,i+1]~dat$agegrp + dat$agegrp2))$coefficients[3,1]]
    UR_incid_no80[cause_name==x & draw==i,pval_age2:=summary(lm(dat[,i+1]~dat$agegrp + dat$agegrp2))$coefficients[3,4]]
    
    UR_incid_no80[cause_name==x & draw==i,coef_age_log:=summary(lm(log(dat[,i+1] + 0.000000000000000000000000001)~dat$agegrp))$coefficients[2,1]]
    UR_incid_no80[cause_name==x & draw==i,pval_age_log:=summary(lm(log(dat[,i+1] + 0.000000000000000000000000001)~dat$agegrp))$coefficients[2,4]]
  }
}
end_time<-Sys.time()
end_time-start_time   # 45 min 


