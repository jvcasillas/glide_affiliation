source(here::here("./rScripts/00_helpers.R"))


# Setup to load data -----------------------------------------------------------

# Store all folders in 'data' directory
# Use regex to exclude anything that is not 
# a folder (excludes p01 and p02 because they 
# didn't complete the task, and 'tidy' because 
# that is where tidy data will be saved)
folders <- dir(path = here("data"), pattern = "^[^.]+$")[-c(1, 2, 3)]

# Store number of folders
participant_length <- length(folders)

# Load carrier task data -------------------------------------------------------

# append path to data files
path_to_carrier <- here(paste0("data/", folders, "/data/carrier"))

# Create empty character vector to hold paths 
children_carrier <- vector("character", length = participant_length)

# For loop to store paths in 'children_carrier' vector 
# Search only for .csv files 
for (i in 1:participant_length) {
  
  # List .csv files in each folder of 'folders'
  # store output in 'children'
  children_carrier[i] <- list.files(path = path_to_carrier[i], 
                                    pattern = ".csv", 
                                    full.names = TRUE)
}

# Read in .csv files, combine into df, 
# create variables .wav filename, save 
# as raw csv
map(.x = children_carrier, .f = read_csv, na = "--undefined--") %>% 
  bind_rows(.) %>% 
  write_csv(., path = here("data", "dataframes", "raw", "carrier_raw.csv"))

