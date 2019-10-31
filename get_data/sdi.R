rm(list=ls())

library(data.table)

sdi<- fread("H:/Dementia/Data_extraction/Diagnosis/st_gpr/st_gpr_data/sdi_the_pc_levels_1_to_3.csv")

loc <- fread("H:/Dementia/Data_extraction/Diagnosis/st_gpr/st_gpr_data/locs_loc_set_id_22.csv")
locs <- loc[parent_id == 102,
            .(location_id,parent_id, ihme_loc_id, level)]
head(locs)

test <- merge(sdi, locs, by = c('location_id'))
test[, .N, by = location_id]

write.csv(test, "H:/Ageing in the USA/data/covs_and_misc/sdi_the_usd_subnationals.csv")