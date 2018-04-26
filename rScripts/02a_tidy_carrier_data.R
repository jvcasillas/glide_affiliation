source(here::here("./rScripts/00_helpers.R"))

# Load raw csv file
car_df <- read_csv(here("data", "dataframes", "raw", "./carrier_raw.csv")) %>%
  separate(., col = Filename, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x)

# Check it
head(car_df)
