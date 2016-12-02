# Example of Scenario Analysis read data
require(lubridate)
require(ggplot2)
require(reshape2)
require(dplyr)

# NASHUA

files <- list.files("../../../_modeling/NASHUA/_APSIM/_APSIM 7.8 forecast calib")
files <- files[grep("out",files)]
files <- c(files[grep("CS_",files)],files[grep("SC_",files)])

s <- data.frame()

for(i in 1:length(files)){
  path <- paste0("../../../_modeling/NASHUA/_APSIM/_APSIM 7.8 forecast calib/",files[i])
  x <- read.table(path,skip = 4, na.strings = "?")
  n <- as.character(unlist(read.table(path,skip=2)[1,]))
  n <- gsub("[[:punct:]]","_",n)
  n <- gsub("paddock_","",n)
  names(x) <- n
  x$rotation <- substr(files[i],1,2)
  x$Nrate <- as.numeric(substr(gsub(".out","",files[i]),4,100))
  s <- rbind(s,x)
  print(files[i])
}


#x <- s
#s <- x

s$Date <- as.Date(s$Date, format="%d/%m/%Y")
s$year <- year(s$Date)
s$site <- "Nashua"

s$yield <- s$soybean_yield + s$maize_yield
s$uptake <- (s$soybean_biomass_n + s$maize_biomass_n)*10
s$grain <- (s$soybean_grain_n + s$maize_grain_n)*10
s$stage <- s$maize_stage + s$soybean_stage
s$precip <- ave(s$rain, paste(s$rotation,s$Nrate,s$year),FUN=cumsum)

s$crop <- ifelse(s$rotation == "CS" , 
                 ifelse(s$year%%2 == 0, "Maize", "Soybean"),
                 ifelse(s$year%%2 == 0, "Soybean", "Maize"))

s$soil_no3ppm <- (s$no3ppm_1_*1 + s$no3ppm_2_*4 + s$no3ppm_3_*5 + s$no3ppm_4_*10 + s$no3ppm_5_*10)/(30) # for 0-30
#s$soil_no3ppm <- (s$no3ppm_1_*1 + s$no3ppm_2_*4 + s$no3ppm_3_*5 + s$no3ppm_4_*10 + s$no3ppm_5_*10 + s$no3ppm_6_*15 + s$no3ppm_7_*15)/(60) # For 0-60cm
s$soil_no3ppm_V6 <- ifelse(s$stage >= 5 & s$stage <= 5.5, s$soil_no3ppm, NA) # Between apsim stages 5 and 5.5 
s$soil_no3ppm_res <- ifelse(s$maize_stage > 10.5, s$soil_no3ppm, NA) # About 7 days after corn maturity

nashua <- s


# Kelley 

files <- list.files("../../../_modeling/COBS/cobs 7.8")
files <- files[grep("out",files)]
files <- c(files[grep("CS_",files)],files[grep("SC_",files)])

s <- data.frame()

for(i in 1:length(files)){
  path <- paste0("../../../_modeling/COBS/cobs 7.8/",files[i])
  x <- read.table(path,skip = 4, na.strings = "?")
  n <- as.character(unlist(read.table(path,skip=2)[1,]))
  n <- gsub("[[:punct:]]","_",n)
  n <- gsub("paddock_","",n)
  names(x) <- n
  x$rotation <- substr(files[i],1,2)
  x$Nrate <- as.numeric(substr(gsub(".out","",files[i]),4,100))
  s <- rbind(s,x)
  print(files[i])
}

#x <- s
#s <- x

s$Date <- as.Date(s$Date, format="%d/%m/%Y")
s$year <- year(s$Date)
s$site <- "Kelley"

s$yield <- s$soybean_yield + s$maize_yield
s$uptake <- (s$soybean_biomass_n + s$maize_biomass_n)*10
s$grain <- (s$soybean_grain_n + s$maize_grain_n)*10
s$stage <- s$maize_stage + s$soybean_stage
s$precip <- ave(s$rain, paste(s$rotation,s$Nrate,s$year),FUN=cumsum)

s$crop <- ifelse(s$rotation == "CS" , 
                 ifelse(s$year%%2 == 0, "Maize", "Soybean"),
                 ifelse(s$year%%2 == 0, "Soybean", "Maize"))

s$soil_no3ppm <- (s$no3ppm_1_*1 + s$no3ppm_2_*4 + s$no3ppm_3_*5 + s$no3ppm_4_*10 + s$no3ppm_5_*10)/(30) # for 0-30
#s$soil_no3ppm <- (s$no3ppm_1_*1 + s$no3ppm_2_*4 + s$no3ppm_3_*5 + s$no3ppm_4_*10 + s$no3ppm_5_*10 + s$no3ppm_6_*15 + s$no3ppm_7_*15)/(60) # For 0-60cm
s$soil_no3ppm_V6 <- ifelse(s$stage >= 5 & s$stage <= 5.5, s$soil_no3ppm, NA) # Between apsim stages 5 and 5.5 
s$soil_no3ppm_res <- ifelse(s$maize_stage > 10.5, s$soil_no3ppm, NA) # About 7 days after corn maturity

cobs <- s

# Merge and save
s <- rbind(cobs,nashua[,names(nashua)[names(nashua) %in% names(cobs)]])
saveRDS(s[s$Nrate != 360,c(1:22,62:length(s))], "_data/scenario.rds")
