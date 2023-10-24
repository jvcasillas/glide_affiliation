
# Source helpers
source(here::here("scripts", "r", "03_load_data.R"))


url <- "https://gitlab.pavlovia.org/jvcasillas/ga_syllabified_check/-/archive/master/ga_syllabified_check-master.zip"

get_data_from_gitlab(url = url)

