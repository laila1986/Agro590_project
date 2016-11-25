# Load packages

require(tidyverse)
require(readr)
require(lubridate)
require(ggthemes)
source("code/multiscenario.r")

# 
soy <- readRDS("data/soybean.rds")
metYears <- readRDS("data/metYears.rds")

soy_price <- 9.5

as_data_frame(soy) %>%
  separate(title, c("site","maturity","planting","residualN","previousCrop","waterTable"), sep = ";") %>%
  mutate(CropYield = CropYield*.0149,
         Revenue = soy_price*CropYield,
         site = factor(gsub("-Soy","",site)),
         maturity = factor(sub("cultivar=Soy_","",maturity)),
         planting = ordered(gsub("date=","",planting), levels= c("15-apr","1-may","15-may","1-jun","15-jun")),
         residualN = factor(as.numeric(gsub("[^[:digit:]]","",residualN))),
         previousCrop = factor(gsub("Residue_SOM=SOM","",previousCrop)),
         waterTable = factor(as.numeric(gsub("[^[:digit:]]","",waterTable)))) %>%
  left_join(metYears) %>%
  select(-plant_density, -AnnualIrrigation, -Date) %>%
  gather("variable","value",AnnualNlossTotal:HarN180, Revenue) %>% 
  group_by(site, maturity, planting, residualN, previousCrop, waterTable, climate,variable) %>% 
  summarise(mean = mean(value, na.rm=T), sd = sd(value,na.rm=T)) %>%
  mutate(cv = sd/mean) -> soy

inputs <- list(
  site = unique(soy$site),
  climate = unique(soy$climate),
  maturity = unique(soy$maturity),
  planting = unique(soy$planting),
  residualN = unique(soy$residualN),
  previousCrop = unique(soy$previousCrop),
  waterTable = unique(soy$waterTable)
)

select_variable <- c("CropYield", "Revenue", "AnnualNlossTotal")

multiscenario_random(inputs,10) %>%
  left_join(soy %>% filter(variable %in% select_variable)) %>%
  ggplot(aes(y=mean, x=scenario)) +
  facet_wrap(~variable, scales = "free",ncol = 3) +
  geom_bar(aes(fill=paste(scenario,site,climate,maturity,planting,residualN,previousCrop,waterTable,sep=";")),
           stat="identity", colour="black") + 
  geom_errorbar(aes(ymin = mean-sd, ymax=mean+sd), width=0.3) +
  labs(x="",y="",fill="Scenarios:") +
  guides(fill=guide_legend(ncol=1, title.position = "top")) +
  theme_linedraw() + theme(legend.position="top") 



