# Classify wether years

met <- read_table("data/Ames.met",skip = 12,col_names = F)

names <- read_lines("data/Ames.met")[11]
names(met) <- unlist(strsplit(names," "))[unlist(strsplit(names," ")) != ""]

met %>%
  mutate(date = as.Date(day - 1, origin = paste0(year,"-01-01")),
         month = month(date),
         temp = (maxt + mint)*0.5,
         season = ifelse(month %in% 4:10,"growing","winter")) %>%
  filter(year < 2016) %>%
  group_by(year, season) %>%
  summarise(temp = mean(temp),
            rain = sum(rain)) %>% 
  filter(season == "growing") %>%
  group_by() %>%
  mutate(mTemp = median(temp), 
         mRain = median(rain),
         temp2 = ifelse(temp > mTemp, "Warm","Cool"), 
         rain2 = ifelse(rain > mRain, "Wet","Dry"),
         climate = paste(temp2,rain2,sep=" and ")) %>%
  select(year,climate) %>%
  saveRDS("data/metYears.rds")
