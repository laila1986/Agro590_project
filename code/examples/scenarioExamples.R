### Examples for creating scenario comparisons 

# Load packages #####################################################
require(tidyverse)

# Load data #########################################################
data <- readRDS("data/scenarios.rds")

# Source helper code ################################################
source("code/extract_keys.R")
source("code/multiscenario_FUN.R")


# Example of soybean ################################################

multiscenario_random(soybeanKey,6) %>%
  left_join(data$soybean %>% 
              inner_join(read_csv("data/dataDictionary_variables.csv") %>% filter(userSelect == 1)) %>%
              mutate(mean = mean*convertionFactor + convertionFactor2,
                     sd = sd*convertionFactor + convertionFactor2)) %>%
  ggplot(aes(y=mean, x=scenario)) +
  facet_wrap(~paste0(name," (",unitEng,") "), scales = "free",ncol = 5) +
  geom_bar(aes(fill=paste(scenario,site,climate,maturity,planting,residualN,previousCrop,waterTable,sep=";")),
           stat="identity", colour="black") + 
  geom_errorbar(aes(ymin = mean-sd, ymax=mean+sd), width=0.3) +
  labs(x="",y="",fill="Scenarios:") +
  guides(fill=guide_legend(ncol=1, title.position = "top")) +
  theme_linedraw() + theme(legend.position="top") 

# Example of corn ##################################################

multiscenario_random(cornKey,3) %>%
  inner_join(data$corn %>% 
              inner_join(read_csv("data/dataDictionary_variables.csv") %>% filter(userSelect == 1)) %>%
              mutate(mean = mean*convertionFactor + convertionFactor2,
                     sd = sd*convertionFactor + convertionFactor2)) %>%
  ggplot(aes(y=mean, x=scenario)) +
  facet_wrap(~paste0(name," (",unitEng,") "), scales = "free",ncol = 5) +
  geom_bar(aes(fill=paste(scenario,site,climate,maturity,planting,Ntime,Nrate,residualN,previousCrop,waterTable,sep="; ")),
           stat="identity", colour="black") + 
  geom_errorbar(aes(ymin = mean-sd, ymax=mean+sd), width=0.3) +
  #geom_text(aes(y=1.06*(mean+sd), label=paste0("±",round(cv*100),"%"))) +
  labs(x="",y="",fill="Scenarios:") +
  guides(fill=guide_legend(ncol=1, title.position = "top")) +
  theme_linedraw() + theme(legend.position="top") 

# Clear the workspace ################################################
rm(list = ls())

