# Load data -------------------------------------------------------------------

# Source helpers
source(here::here("scripts", "r", "00_helpers.R"))

# Load carrier data ------------------------------------------------------------
carrier_tc_final <- read_csv(here("data", "dataframes", "tidy", "carrier_timecourse_subset_tidy.csv"))
carrier_tc_iu <- read_csv(here("data", "dataframes", "tidy", "carrier_timecourse_subset_iu_tidy.csv"))

carrier_dur_final <- read_csv(here("data", "dataframes", "tidy", "carrier_duration_subset_tidy.csv"))
carrier_dur_iu <- read_csv(here("data", "dataframes", "tidy", "carrier_duration_iu_tidy.csv"))


# Load syllabification data ----------------------------------------------------
syllabified_trip <- read_csv(here("data", "dataframes", "tidy", "./syllabified_triphthong_tidy.csv"))
