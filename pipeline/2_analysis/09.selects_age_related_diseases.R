###############################################
#
# This file reads the regression outputs and 
# binds them into a single df and determines 
# age related disease by identifiying casues with beta(age)
# is positive for 95% of the draws
#
##############################################
# cleaning environment
rm(list= ls())

# libraries

library(data.table)


# Set directories 
if (Sys.info()["sysname"] =="Linux") {
  root <-"/ihme/homes/ppedroza/Ageing_USA/"
} else {
  root <-"H:/Ageing_USA/"
}

#######
##
# Incidence no 80! 
##
#######


# Makes a lit of all the files
files <- list.files(paste0(root, "data/intermediate/1_regression_output/inc_no80"), full.names = T)

i <- 0 # A little ticker to see the aggregation progress

dt <- data.table()# blank dt

for (file in files){
  # keeping track of the loop progress
  i <- i  + 1
  print(i)
  
  # reads data
  data <- fread(file)
  print(dim(data))
  
  # binding rows together
  dt <- rbind(dt, data)
  
  # Pring dims of new dataframe
  print(dim(dt))
  
}

# Rounding coeficients to see if this makes a difference in the 
# age_related diseases

dt[, coef_age1_round := round(coef_age1, 4)]
dt[, coef_age2_round := round(coef_age2, 4)]
dt[, coef_age_log_round := round(coef_age_log, 4)]

df <- as.data.frame(dt)


library(dplyr)

df2 <- df %>%
  group_by(cause_name) %>%
  summarize(
    pos1 = mean(coef_age1_round > 0),
    pos2 = mean(coef_age2_round > 0), 
    pos3 = mean(coef_age_log_round > 0)
  )

ard_1 <- filter(df2, pos1 >.94)
ard_2 <- filter(ard_1, pos2 > .94)


write.csv(ard_2,
          paste0(root, "outputs/09.age_related_diases_inc_no_80_02_03_20.csv"),
          row.names = F)

#######
##
# Incidence all adults
##
#######


# Makes a lit of all the files
files <- list.files(paste0(root, "data/intermediate/1_regression_output/inc_all_ages"), full.names = T)

# Brings everything together

i <- 0 # A little ticker to see the aggregation progress
dt <- data.table()# blank dt

for (file in files){
  # keeping track of the loop progress
  i <- i  + 1
  print(i)
  
  # reads data
  data <- fread(file)
  print(dim(data))
  
  # binding rows together
  dt <- rbind(dt, data)
  
  # Pring dims of new dataframe
  print(dim(dt))
  
}

# turns data.table into a df so I can use dplyr

dt[, coef_age1_round := round(coef_age1, 4)]
dt[, coef_age2_round := round(coef_age2, 4)]
dt[, coef_age_log_round := round(coef_age_log, 4)]

df <- as.data.frame(dt)

# If the coeficient is positive is calculates the mean.
# If mean == 0, all draws where negative
# If mean == 1, all draws where positive
# If mean between 0 and 1, it's the ratio of positive draws over the 1000 draws

df2 <- df %>%
  group_by(cause_name) %>%
  summarize(
    pos1 = mean(coef_age1_round > 0),
    pos2 = mean(coef_age2_round > 0),
    pos3 = mean(coef_age_log_round > 0)
  )

ard_1 <- filter(df2, pos1 >.94)
ard_2 <- filter(ard_1, pos2 > .94)


write.csv(ard_2,
          paste0(root, "outputs/09.age_related_diases_inc_all_adults_02_03_20.csv"),
          row.names = F)


#######
##
# Prevalence no 80! 
##
#######


# Makes a lit of all the files
files <- list.files(paste0(root, "data/intermediate/1_regression_output/pre_no80"), full.names = T)

i <- 0 # A little ticker to see the aggregation progress

dt <- data.table()# blank dt

for (file in files){
  # keeping track of the loop progress
  i <- i  + 1
  print(i)
  
  # reads data
  data <- fread(file)
  print(dim(data))
  
  # binding rows together
  dt <- rbind(dt, data)
  
  # Pring dims of new dataframe
  print(dim(dt))
  
}

dt[, coef_age1_round := round(coef_age1, 4)]
dt[, coef_age2_round := round(coef_age2, 4)]
dt[, coef_age_log_round := round(coef_age_log, 4)]

df <- as.data.frame(dt)


df2 <- df %>%
  group_by(cause_name) %>%
  summarize(
    pos1 = mean(coef_age1_round > 0),
    pos2 = mean(coef_age2_round > 0),
    pos3 = mean(coef_age_log_round > 0)
  )

ard_1 <- filter(df2, pos1 >.94)
ard_2 <- filter(ard_1, pos2 > .94)


write.csv(ard_2,
          paste0(root, "outputs/09.age_related_diases_pre_no_80_02_03_20.csv"),
          row.names = F)



#######
##
# Prevalence all adults
##
#######


# Makes a lit of all the files
files <- list.files(paste0(root, "data/intermediate/1_regression_output/pre_all_adults"), full.names = T)

# Brings everything together

i <- 0 # A little ticker to see the aggregation progress
dt <- data.table()# blank dt

for (file in files){
  # keeping track of the loop progress
  i <- i  + 1
  print(i)
  
  # reads data
  data <- fread(file)
  print(dim(data))
  
  # binding rows together
  dt <- rbind(dt, data)
  
  # Pring dims of new dataframe
  print(dim(dt))
  
}

# turns data.table into a df so I can use dplyr

dt[, coef_age1_round := round(coef_age1, 4)]
dt[, coef_age2_round := round(coef_age2, 4)]
dt[, coef_age_log_round := round(coef_age_log, 4)]


df <- as.data.frame(dt)

# If the coeficient is positive is calculates the mean.
# If mean == 0, all draws where negative
# If mean == 1, all draws where positive
# If mean between 0 and 1, it's the ratio of positive draws over the 1000 draws



df2 <- df %>%
  group_by(cause_name) %>%
  summarize(
    pos1 = mean(coef_age1_round > 0),
    pos2 = mean(coef_age2_round > 0),
    pos3 = mean(coef_age_log_round > 0)
  )

ard_1 <- filter(df2, pos1 >.94)
ard_2 <- filter(ard_1, pos2 > .94)


write.csv(ard_2,
          paste0(root, "outputs/09.age_related_diases_pre_all_adults_02_03_20.csv"),
          row.names = F)
