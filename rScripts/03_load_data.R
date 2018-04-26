source(here::here("./rScripts/00_helpers.R"))

# Load raw csv file
car_df <- read_csv(here("data", "dataframes", "raw", "./carrier_raw.csv"))

# Check it
head(car_df)


# Load new file
syl_df <- read_csv(here("data", "dataframes", "raw", "./syllable_raw.csv"))

# Check it
head(syl_df)
