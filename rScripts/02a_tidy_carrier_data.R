source(here::here("./rScripts/00_helpers.R"))

# Load raw csv file
car_df <- read_csv(here("data", "dataframes", "raw", "./carrier_raw.csv")) 

head(car_df)
glimpse(car_df)

# Tidy time course data --------------------------------------------------------
car_timecourse <- car_df %>%
  separate(., col = Filename, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x) %>% 
  filter(., status == 'hit') %>% 
  gather(., metric, value, 
           -c(participant, exp, item, status, TextGridLabel, duration)) %>% 
  separate(., metric, into = c('metric', 'time_course'), sep = "_") %>% 
  mutate(., time_course = as.numeric(time_course), 
            TextGridLabel = as.factor(TextGridLabel)) %>% 
  group_by(., participant, item, TextGridLabel, metric) %>% 
  mutate(., identifier = seq_along(item)) %>% 
  ungroup(.) %>% 
  spread(., metric, value)









# tidy duration data -----------------------------------------------------------
car_duration <- car_df %>%
  separate(., col = Filename, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(participant:duration, -x) %>% 
  filter(., status == 'hit')








car_duration %>% 
  group_by(., TextGridLabel) %>% 
  summarize(., mean_dur = mean(duration), sd_dur = sd(duration))
