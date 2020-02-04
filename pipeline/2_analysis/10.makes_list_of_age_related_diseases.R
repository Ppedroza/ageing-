rm(list=ls())

# Set directories 
if (Sys.info()["sysname"] =="Linux") {
  root <-"/ihme/homes/ppedroza/Ageing_USA/"
} else {
  root <-"H:/Ageing_USA/"
}

# Loading libraries
library(data.table)


inc_all <- fread(paste0(root, 
                        'outputs/age_related_diases_inc_all_adults.csv'))

inc_n80 <- fread(paste0(root, 
                        'outputs/age_related_diases_inc_no_80.csv'))

pre_all <- fread(paste0(root, 
                        'outputs/age_related_diases_pre_all_adults.csv'))

pre_n80 <- fread(paste0(root, 
                        'outputs/age_related_diases_pre_no_80.csv'))


# Making a unique list of age_related_causes
inc <- merge(inc_all, inc_n80, by = 'cause_name', all = T, suffixes = c(".all", ".no_80"))
inc_causes <- unique(inc)

# write.csv(inc, paste0(root,
#                  'outputs/10.inc_age_related_diseases.csv'),
#           row.names = F)

pre <- merge(pre_all, pre_n80, by = 'cause_name', all = T, suffixes = c(".all", ".no_80"))
pre <- unique(pre)
# write.csv(pre, paste0(root,
#                  'outputs/10.pre_age_related_diseases.csv'),
#           row.names = F)

# Comparing American causes to 

data <- rbind(inc, pre)
usa <- data[pos2.no_80 > .949, ]
usa_arc <- unique(usa$cause_name)


glo_arc <- fread(paste0(root, "data/covs_and_misc/age_related_cause.csv"))
glo_arc <- glo_arc[!is.na(V1),]

glo_arc <- unique(glo_arc$V2)

matches <- intersect(glo_arc, usa_arc)
View(matches)

difference <- setdiff(usa_arc, glo_arc)
View(difference)

global_causes_not_in_usa <- setdiff(glo_arc, usa_arc)
View(global_causes_not_in_usa)

