# Download data from Phase 2 --------------------------------------------------
#
# Author: Joseph V. Casillas
# Description: This script will download the phase 2 data from the gitlab repo
#
# -----------------------------------------------------------------------------




# Source helpers --------------------------------------------------------------

source(here::here("scripts", "r", "03_load_data.R"))

# -----------------------------------------------------------------------------




# Get data --------------------------------------------------------------------

url <- "https://gitlab.pavlovia.org/jvcasillas/ga_syllabified_check/-/archive/master/ga_syllabified_check-master.zip"

get_data_from_gitlab(url = url)

# -----------------------------------------------------------------------------
