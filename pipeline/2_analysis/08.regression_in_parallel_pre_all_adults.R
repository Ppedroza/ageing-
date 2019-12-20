print(commandArgs())
library(data.table)
# read in data
data <- fread("/ihme/homes/ppedroza/Ageing_USA/data/intermediate/07.pre_all_adults.csv")
# subset to a cause

# Making dataset to store results
causes_inc_all_adults <- data[,unique(cause_name,)] # 30
UR_prev_all_adults <- data.table(cause_name=rep(causes_inc_all_adults,each=1000),draw=c(0:999))
draws<-c(0:999)

ccc <- commandArgs()[8]
print(paste0("This is the cause id currently working on ", ccc))
# regression
# no 80+ 

# running it just for one cause
start_time<-Sys.time()

#Subset to a single cause. Original data
dat<-data.frame(subset(data, cause_id==ccc))
dat$cause_id <- NULL
# cause you are currently working on
x <- unique(dat$cause_name)

# subsets to a single cause. Stores results
UR_prev_all_adults_s <- UR_prev_all_adults[cause_name ==x, ]

for (i in draws){
  UR_prev_all_adults_s[cause_name==x & draw==i,coef_age1:=summary(lm(dat[,i+1]~dat$agegrp))$coefficients[2,1]]
  UR_prev_all_adults_s[cause_name==x & draw==i,pval_age1:=summary(lm(dat[,i+1]~dat$agegrp))$coefficients[2,4]]
  UR_prev_all_adults_s[cause_name==x & draw==i,coef_age2:=summary(lm(dat[,i+1]~dat$agegrp + dat$agegrp2))$coefficients[3,1]]
  UR_prev_all_adults_s[cause_name==x & draw==i,pval_age2:=summary(lm(dat[,i+1]~dat$agegrp + dat$agegrp2))$coefficients[3,4]]
  
  UR_prev_all_adults_s[cause_name==x & draw==i,coef_age_log:=summary(lm(log(dat[,i+1] + 0.000000000000000000000000001)~dat$agegrp))$coefficients[2,1]]
  UR_prev_all_adults_s[cause_name==x & draw==i,pval_age_log:=summary(lm(log(dat[,i+1] + 0.000000000000000000000000001)~dat$agegrp))$coefficients[2,4]]
}

end_time<-Sys.time()
end_time-start_time   # 55.55111 mins for a single cause


# save file
write.csv(UR_prev_all_adults_s, 
          paste0("/ihme/homes/ppedroza/Ageing_USA/data/intermediate/regression_output/pre_all_adults/", x, ".csv"), 
          row.names = F)

