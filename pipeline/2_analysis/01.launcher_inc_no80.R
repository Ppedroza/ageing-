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

inc <- read_feather(paste0(root, 'data/intermediate/00.inc_cleaned.feather'))
inc_1 <- as.data.table(inc)
################################
#
# First we run everything for under 80 and then 
# we run everything for all ages
################################


## 
# Subseting to less than 80
##
incid_no80 <- inc_1[agegrp<82, ]

# Getting rid of causes that have zeros

cause_no_incid<-incid_no80[draw_0==0,.(cause_name)]
cause_no_incid[ , ':='( count = .N ) , by = cause_name ]
cause_no_incid[, table(count)]
cause_no_incid <- unique(cause_no_incid)

# make a list causes that have zeros
causes_with_zeros <-cause_no_incid[count>260, unique(cause_name)] 

# there are 27 causes that have zeros for incidence. The smallest count of zeros is 261. 

##
# Selecting causes that don't have zeros
##

global_incid_no80 <- incid_no80[!cause_name %in% c(causes_with_zeros)]
global_incid_no80[,unique(cause_name)] # 174 causes

# Making a list of causes to run the regression
causes <- unique(global_incid_no80$cause_id)

# I save the file here so the child script can read it
write.csv(global_incid_no80, paste0(root, 'data/intermediate/01.inc_no_80.csv'), row.names = F)

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
                      ccc, "/ihme/homes/ppedroza/Ageing_USA/ageing-/pipeline/2_analysis/02.regression_in_parallel_inc_no80.R", ccc)
  system(qsub_str)

  Sys.sleep(0.5)
}

