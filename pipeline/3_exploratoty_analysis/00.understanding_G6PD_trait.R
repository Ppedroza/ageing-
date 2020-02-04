########################################################################
# The prevalence of G6PD trait looks pretty flat almost until about 65,
# however it's being selected as a age-related disease. I'm going to run
# the regression only on G6PD and plot the results to understand the 
# results better. 
#
########################################################################
rm(list = ls())


library(data.table)


# Set directories 
if (Sys.info()["sysname"] =="Linux") {
  root <-"/ihme/homes/ppedroza/Ageing_USA/"
} else {
  root <-"H:/Ageing_USA/"
}


# loading prevalence data
pre1 <- fread(paste0(root, "data/raw/prevalence/839.csv"))
pre2 <- fread(paste0(root, "data/raw/prevalence/839_pre.csv"))

# Bringing everything together
g6pd <- rbind(pre1, pre2)
g6pd <- g6pd[year_id == 2017,]

# data inventory
g6pd[, .N, by = age_group_id] # 17 age_groups 15 to 100 years old
g6pd[, .N, by = year_id] # 2017
g6pd[, .N, by = location_id] # 52 locs. (US states)
g6pd[, .N, by = cause_id] # 839 G6PD trait
g6pd[, .N, by = measure_id] # 5 prevalence
g6pd[, .N, by =  metric_id] # 3 rate
g6pd[, .N, by = sex_id] # 3 both

# cleaning data before running the regression

g6pd[, sex_id:=NULL]
g6pd[, measure_id:=NULL]
g6pd[, metric_id:=NULL]
g6pd[, year_id:=NULL]
g6pd[, location_id:=NULL]

# Cleaning the age_group_id variable

g6pd[age_group_id==8 , agegrp:=17] ; 
g6pd[age_group_id==9 , agegrp:=22] ; g6pd[age_group_id==10 , agegrp:=27]
g6pd[age_group_id==11 , agegrp:=32] ; g6pd[age_group_id==12 , agegrp:=37]
g6pd[age_group_id==13 , agegrp:=42] ; g6pd[age_group_id==14 , agegrp:=47]
g6pd[age_group_id==15 , agegrp:=52] ; g6pd[age_group_id==16 , agegrp:=57]
g6pd[age_group_id==17 , agegrp:=62] ; g6pd[age_group_id==18 , agegrp:=67]
g6pd[age_group_id==19 , agegrp:=72] ; g6pd[age_group_id==20 , agegrp:=77]
g6pd[age_group_id==30 , agegrp:=82] ; g6pd[age_group_id==31 , agegrp:=87] 
g6pd[age_group_id==32 , agegrp:=92] ; g6pd[age_group_id==235 , agegrp:=100] 

# Removing unnecessary columns
g6pd[, age_group_id:=NULL]


# Calculating the squared of age
g6pd[,agegrp2:=agegrp^2]

###
## running the regression in the entire dataset (all ages)
###

x <- unique(g6pd$cause_id)

# Creating df to save data
UR_incid <- data.table(cause_id=rep(x,each=1000),draw=paste0('draw_', (0:999))) 


# alternative scenario
id.vars <- c('cause_id', 'agegrp', 'agegrp2')

g6pd_l <- melt(g6pd, 
              id.vars = id.vars)

setnames(g6pd_l, old = "variable", new = "draw")

# running the regression
g6pd <- as.data.frame(g6pd)
start_time<-Sys.time()

draws<- paste0('draw_', (0:999))

for (i in draws){

  UR_incid[cause_id==x & draw==i,coef_age1:=summary(lm(g6pd[,i]~g6pd$agegrp))$coefficients[2,1]]
  UR_incid[cause_id==x & draw==i,pval_age1:=summary(lm(g6pd[,i]~g6pd$agegrp))$coefficients[2,4]]
  
  UR_incid[cause_id==x & draw==i,coef_age2:=summary(lm(g6pd[,i]~g6pd$agegrp + g6pd$agegrp2))$coefficients[3,1]]
  UR_incid[cause_id==x & draw==i,pval_age2:=summary(lm(g6pd[,i]~g6pd$agegrp + g6pd$agegrp2))$coefficients[3,4]]
  
  # UR_incid[cause_id==x & draw==i,coef_age_log:=summary(lm(log(g6pd[,i] + 0.000000000000000000000000001)~g6pd$agegrp))$coefficients[2,1]]
  # UR_incid[cause_id==x & draw==i,pval_age_log:=summary(lm(log(g6pd[,i] + 0.000000000000000000000000001)~g6pd$agegrp))$coefficients[2,4]]
}

end_time<-Sys.time()
end_time-start_time   

write.csv(UR_incid, 
          paste0(root, "outputs/exploratory_analysis/00.g6pd_regression_output.csv"), 
          row.names = F)

