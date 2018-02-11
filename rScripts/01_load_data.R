source(here::here("./rScripts/00_helpers.R"))


# Load syllabification task data -----------------------------------------------

# Create vector with col names
syllabified_cols <- c(
  'prefix', 
  'syll1Lab', 'syll1Dur', 
  'syll2Lab', 'syll2Dur', 
  'syll3Lab', 'syll3Dur', 
  'syll4Lab', 'syll4Dur', 
  'syll5Lab', 'syll5Dur', 
  'critOnsetLab', 'critOnsetDur', 
  'labID')

# Store all folders in 'data' directory
# Use regex to exclude anything that is not 
# a folder (excludes p01 and p02 because they 
# didn't complete the task, and 'tidy' because 
# that is where tidy data will be saved)
folders <- dir(path = here("data"), pattern = "^[^.]+$")[-c(1, 2, 9)]

# Store number of folders
participant_length <- length(folders)

# append path to data file
path_to_data <- here(paste0("data/", folders, "/data/syllabified"))

# Create empty character vector to hold paths 
children <- vector("character", length = participant_length)

# For loop to store paths in 'children' vector 
# Search only for .csv files 
for (i in 1:participant_length) {
  
  # List .Rmd files in each folder of 'folders'
  # store output in 'children'
  children[i] <- list.files(path = path_to_data[i], 
                            pattern = ".csv", 
                            full.names = TRUE)
}


map(.x = children, .f = read_csv, col_names = syllabified_cols) %>% 
  bind_rows(.) %>% 
  separate(., col = prefix, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x) %>% 
  write_csv(., path = here("data", "tidy", "syllable_clean.csv"))


