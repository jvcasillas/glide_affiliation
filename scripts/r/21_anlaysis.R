# Phase 2: analysis -----------------------------------------------------------
#
# Authors: Miriam Rodríguez and Joseph V. Casillas
# Last update: 20240508
# Description: 
#  - This script will load and tidy the phase 2 data
#  - This script contains all of the statistical analyses
#
# -----------------------------------------------------------------------------



# Source helpers and packages -------------------------------------------------

source(here::here("scripts", "r", "00_helpers.R"))

# -----------------------------------------------------------------------------




# Load data -------------------------------------------------------------------

# Make vector of the columns we want
phase2_cols <- c(
  "participant", "id", "item", "response", "op1", "op2", "op3", 
  "mouse.clicked_name", "textbox_followup.text"
)

# Get a list of all csv files
# Load them as individual data frames inside a list
# Select only the columns you want (my_cols)
# Bind all the list elements into a single data frame
phase2_temp <- dir_ls(path = here("data", "phase_2"), regexp = ".csv") |> 
  as.list() |> 
  map(read_csv) |> 
  map(.f = function(x) {x[, names(x) %in% phase2_cols]}) |> 
  do.call(what = "rbind", args = _) 

# -----------------------------------------------------------------------------




# Tidy phase 2 data -----------------------------------------------------------

# Pipe
#  - remove unwanted rows (practice trials, routine clicks)
#  - rename columns
#  - recode participant responses to reflect actual text (i.e., "chia-ba" and 
#    not "text_option_1")
#  - change uppercase responses to lowercase
phase_2 <- phase2_temp |> 
  filter(!is.na(mouse.clicked_name)) |> 
  rename(
    id = participant, 
    speaker_id = id, 
    common_response = response, 
    response = mouse.clicked_name, 
    response_other = textbox_followup.text
  ) |> 
  mutate(
    response = case_when(
      response == "text_option_1"     ~ op1, 
      response == "text_option_2"     ~ op2, 
      response == "text_option_3"     ~ op3, 
      response == "text_option_other" ~ response_other 
    ), 
    response = str_to_lower(response)
  ) |> 
  select(-response_other)

# -----------------------------------------------------------------------------




# Analyses --------------------------------------------------------------------

# Miriam: 
# You can start here. The dataframe you will work with is 'phase_2'
# Don't worry about making any plots for now. Just do the analyses and we 
# will go from there (the plots and other things will be slightly different 
# so we can talk about that later). 
# When you save models you have to make sure you give them new names so you 
# save over the old ones. Ex: 
#
# Old example/name
# file = here("models", "b_multi_0"))
#
# New example/name
# file = here("models", "b_multi_0_phase2"))
#
# I'm sure I am forgetting something, so just give it a go and let me know 
# if/when you have any issues. 
#






# -----------------------------------------------------------------------------

