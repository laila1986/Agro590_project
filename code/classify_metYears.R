# Classify wether years
require(lubridate)

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
  left_join(
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
      mutate(q25Temp = quantile(temp,0.25), 
             q75Temp = quantile(temp,0.75),
             q25Rain = quantile(rain,0.25), 
             q75Rain = quantile(rain,0.75),
             temp2 = ifelse(temp > q25Temp & temp < q75Temp,1,0), 
             rain2 = ifelse(rain > q25Rain & rain < q75Rain,1,0),
             climate2 = ifelse(temp2*rain2==1,"Average","0")) %>%
      select(year,climate2)
  ) %>%
  mutate(climate = as.factor(ifelse(climate2 == "Average","Average",climate))) %>%
  select(year,climate) %>% saveRDS("data/metYears.rds")
