### Script for tidying the corn and soybean data 

# Load packages #######################################################
require(tidyverse)
require(lubridate)

# Soybean data tidying ################################################

soy <- readRDS("data/soybean.rds")
metYears <- readRDS("data/metYears.rds")

soy_price <- 10/60/0.454/0.85 # $/kg dm

as_data_frame(soy) %>%
  separate(title, c("site","maturity","planting","residualN","previousCrop","waterTable"), sep = ";") %>%
  mutate(SoyYield = CropYield,
         Revenue = soy_price*CropYield,
         site = factor(gsub("-Soy","",site)),
         maturity = factor(sub("cultivar=Soy_","",maturity)),
         planting = ordered(gsub("date=","",planting), levels= c("15-apr","1-may","15-may","1-jun","15-jun")),
         residualN = factor(as.numeric(gsub("[^[:digit:]]","",residualN))),
         previousCrop = factor(gsub("Residue_SOM=SOM","",previousCrop)),
         waterTable = factor(as.numeric(gsub("[^[:digit:]]","",waterTable)))) %>%
  left_join(metYears) %>%
  select(-plant_density, -AnnualIrrigation, -Date) %>%
  gather("variable","value",AnnualNlossTotal:HarN180, Revenue,SoyYield) %>% 
  group_by(site, maturity, planting, residualN, previousCrop, waterTable, climate,variable) %>% 
  summarise(mean = mean(value, na.rm=T), sd = sd(value,na.rm=T)) %>%
  mutate(cv = sd/mean) -> soy

# Corn data tidying ###################################################

corn <- readRDS("data/corn.rds")
metYears <- readRDS("data/metYears.rds")

corn_price <- 4/56/0.454/0.85 # $/kg dm

as_data_frame(corn) %>%
  separate(title, c("site","maturity","planting","FallN","SpringN","residualN","previousCrop","waterTable"), sep = ";") %>%
  mutate(CornYield = CropYield,
         Revenue = corn_price*CropYield,
         site = factor(gsub("-Corn","",site)),
         maturity = factor(sub("cultivar=Corn_","",maturity)),
         FallN = as.numeric(gsub("[^[:digit:]]","",FallN)),
         SpringN = as.numeric(gsub("[^[:digit:]]","",SpringN)),
         planting = ordered(gsub("date=","",planting), levels= c("15-apr","1-may","15-may","1-jun")),
         residualN = factor(as.numeric(gsub("[^[:digit:]]","",residualN))),
         previousCrop = factor(gsub("Residue_SOM=SOM","",previousCrop)),
         waterTable = factor(as.numeric(gsub("[^[:digit:]]","",waterTable)))) %>%
  mutate(Ntime = as.factor(ifelse(SpringN > 0, "UAN injected at planting", ifelse(FallN > 0, "Fall Ammonia", "No fertilizer"))),
         Nrate = as.factor(SpringN + FallN))  %>%
  group_by(site, maturity, planting, residualN, previousCrop, waterTable, year) %>% 
  mutate(CornYield0 = sum(ifelse(Ntime == "No fertilizer", CornYield, 0)),
         ReturnToN = corn_price*(CornYield - CornYield0)/(as.numeric(as.character(Nrate))),
         Ntime = as.factor(ifelse(Ntime %in% c("No fertilizer", "UAN injected at planting"), "UAN injected at planting", "Fall Ammonia"))) %>%
  left_join(metYears) %>%
  select(-plant_density, -AnnualIrrigation, -Date) %>%
  gather("variable","value",AnnualNlossTotal:HarN180, Revenue, CornYield, ReturnToN) %>% 
  group_by(site, maturity, Ntime, Nrate, planting, residualN, previousCrop, waterTable, climate,variable) %>% 
  summarise(mean = mean(value, na.rm=T), sd = sd(value,na.rm=T)) %>%
  mutate(cv = sd/mean) -> corn

# make a copy of corn Nrate 0 
x <- corn[corn$Nrate == 0,]
x$Ntime <- "Fall Ammonia"
corn <- rbind(corn,x)
corn$Ntime <- as.factor(corn$Ntime)

# Save sata object #####################################################

saveRDS(list(corn = as_data_frame(corn) , soybean = as_data_frame(soy)),"data/scenarios.rds")

# Clear the workspace ##################################################
rm(list = ls())
