### Script for extracting and compiling corn data from Apsim .out files

# Load packages ################################################################
require(readr)

# Unzip database ###############################################################
rawdata <- "rawdata.zip"
unzip(paste0("data/",rawdata),exdir="data/temp")

# Compiling files #############################################################
base_path <- paste0(gsub(".zip","",paste0("data/temp/",rawdata)),"/corn/")

files <- list.files(base_path)

# Empty data frames for loop outputs
out <- data.frame()
report <- data.frame()

# Loop for compiling corn dataset
for(i in 1:length(files)){
  names <- read_lines(paste0(base_path,files[i]))[4]
  table <- read.table(paste0(base_path,files[i]),skip = 5, na = "?", header = F)
  names(table) <-  unlist(strsplit(names," "))[unlist(strsplit(names," ")) != ""]
  table$title <- files[i]
  out <- rbind(out,table)
  report <-rbind(report,data.frame(title=files[i], no_years=length(table$year)))
  cat("\r", i, "of", length(files),"files")
  #unlink(paste0(base_path,files[i]), recursive = FALSE)
}

# Check errors in simulations #################################################

# Numer of simulations with issues
length(report$no_years[report$no_years < 36])
# As percent of all sims
length(report$no_years[report$no_years < 36])/length(report$no_years)*100

# Save compiled data and clear workspace #####################################

saveRDS(out,"data/corn.rds")
saveRDS(report, "data/corn_report.rds")

# delete temp files
unlink("data/temp/", recursive = TRUE)

# Clear the workspace
rm(list = ls())

