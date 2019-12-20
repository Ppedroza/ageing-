#### Normal Run Launcher ####
##########################################################
# This file: 
# 1. reads all data
# 2. creates a file with data bellow 80
# 3. removes causes that have more than 13 zeros in draw_0
# 4. calls child script to run regression in parallel
# for adults bellow 80.
##########################################################


# set workind directory
rm(list = ls())

# Clean environment
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

pre <- read_feather(paste0(root, 'data/intermediate/00.prev_cleaned.feather'))
pre_1 <- as.data.table(pre)
################################
#
# First we run everything for under 80 and then 
# we run everything for all ages
################################


## 
# Subseting to less than 80
##
prev_no80 <- pre_1[agegrp<82, ]

# Getting rid of causes that have zeros

cause_no_prev<-prev_no80[draw_0==0,.(cause_name)]
cause_no_prev[ , ':='( count = .N ) , by = cause_name ]
cause_no_prev[, table(count)]
cause_no_prev <- unique(cause_no_prev)

# make a list causes that have zeros
causes_with_zeros <-cause_no_prev[count>13,unique(cause_name)] 

# there are 51 causes that have zeros for prevalence. The smallest count of zeros is 13. 
# most of these causes have more than 100 zeros some have more than 600

##
# Selecting causes that don't have zeros
##

global_prev <- pre_1[!cause_name %in% c(causes_with_zeros)]
global_prev[,unique(cause_name)] # 30 causes

# Making a list of causes to run the regression
causes <- unique(global_prev$cause_id)

# I save the file here so the child script can read it
write.csv(global_prev, paste0(root, 'data/intermediate/07.pre_all_adults.csv'), row.names = F)

##
# Runs regression
##

setwd(root)
# User Inputs
## ihme username
user <- "ppedroza"
# child script 


for (ccc in causes) {
  jname <- paste0("reg_", ccc)
  qsub_str <- sprintf(paste("qsub -N reg_%s -l m_mem_free=18G -l fthread=6 -P ihme_general -q all.q",
                            "-e /homes/ppedroza/cluster_errors/  -o /homes/ppedroza/cluster_output/",
                            "/ihme/singularity-images/rstudio/shells/execRscript.sh -i /ihme/singularity-images/rstudio/ihme_rstudio_3602.img",
                            "-s %s %s", sep=" "),
                      ccc, "/ihme/homes/ppedroza/Ageing_USA/ageing-/pipeline/2_analysis/08.regression_in_parallel_pre_all_adults.R", ccc)
  system(qsub_str)

  Sys.sleep(0.5)
}

