source(here::here("./rScripts/00_helpers.R"))

# Load carrier data ------------------------------------------------------------
carrier_dur <- read_csv(here("data", "dataframes", "tidy", "./carrier_duration_tidy.csv"))
carrier_tc  <- read_csv(here("data", "dataframes", "tidy", "./carrier_duration_tidy.csv"))

# Check it
glimpse(carrier_dur)
glimpse(carrier_tc)


# Load syllabification data ----------------------------------------------------
syllabified_trip <- read_csv(here("data", "dataframes", "tidy", "./syllabified_tripthong_tidy.csv"))

# Check it
glimpse(syllabified_trip)
