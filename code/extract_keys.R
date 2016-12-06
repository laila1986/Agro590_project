### Extract key from data 

# Load data #########################################################
#data <- readRDS("data/scenarios.rds")

# Inputs ############################################################

soybeanKey <- list(
  site = unique(data$soybean$site),
  climate = unique(data$soybean$climate),
  maturity = unique(data$soybean$maturity),
  planting = unique(data$soybean$planting),
  residualN = unique(data$soybean$residualN),
  previousCrop = unique(data$soybean$previousCrop),
  waterTable = unique(data$soybean$waterTable)
)

cornKey <- list(
  site = unique(data$corn$site),
  climate = unique(data$corn$climate),
  maturity = unique(data$corn$maturity),
  planting = unique(data$corn$planting),
  residualN = unique(data$corn$residualN),
  previousCrop = unique(data$corn$previousCrop),
  Ntime = unique(data$corn$Ntime),
  Nrate = unique(data$corn$Nrate),
  waterTable = unique(data$corn$waterTable)
)

variables <- c(1:length((read_csv("data/dataDictionary_variables.csv") %>% filter(userSelect == 1))$name))
names(variables) <- (read_csv("data/dataDictionary_variables.csv") %>% filter(userSelect == 1))$name 
