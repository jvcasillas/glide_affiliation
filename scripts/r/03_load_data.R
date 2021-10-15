# Load data -------------------------------------------------------------------

# Source helpers
source(here::here("scripts", "r", "00_helpers.R"))



# Load carrier data ------------------------------------------------------------
carrier_dur <- read_csv(here("data", "dataframes", "tidy", "./carrier_duration_tidy.csv"))
carrier_tc  <- read_csv(here("data", "dataframes", "tidy", "./carrier_timecourse_tidy.csv"))

# Check it
#glimpse(carrier_dur)
#glimpse(carrier_tc)


# Load syllabification data ----------------------------------------------------
syllabified_trip <- read_csv(here("data", "dataframes", "tidy", "./syllabified_triphthong_tidy.csv"))

# Check it
#glimpse(syllabified_trip)
