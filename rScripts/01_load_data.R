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

# append path to data file
path_to_syllabified <- here(paste0("data/", folders, "/data/syllabified"))

# Create empty character vector to hold paths 
children_syllabified <- vector("character", length = participant_length)

# For loop to store paths in 'children_syllabified' vector 
# Search only for .csv files 
for (i in 1:participant_length) {
  
  # List .csv files in each folder of 'folders'
  # store output in 'children'
  children_syllabified[i] <- list.files(path = path_to_syllabified[i], 
                                        pattern = ".csv", 
                                        full.names = TRUE)
}

# Load csv files, combine them into a single df, 
# add column names, add variables from .wav file name, 
# and save as raw csv file
map(.x = children_syllabified, .f = read_csv, col_names = syllabified_cols) %>% 
  bind_rows(.) %>% 
  separate(., col = prefix, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x) %>% 
  write_csv(., path = here("data", "dataframes", "raw", "syllable_raw.csv"))

# Load new file
syl_df <- read_csv(here("data", "dataframes", "raw", "./syllable_raw.csv"))

# Check it
head(syl_df)

# Get vector of unique words
unique(syl_df$item)

# Get critical items
critical_items <- c(
  "costonhialo", "lakabiaisto", "lakabuaisto", 
  "lakadiaisto", "lakaduaisto", "lakafiaisto", 
  "lakafuaisto", "lakagiaisto", "lakaguaisto", 
  "lakakiaisto", "lakakuaisto", "lakapiaisto", 
  "lakapuaisto", "lakatiaisto", "lakatuaisto"
)

# extra = hiato
# error = simplification
# NA = glide

syl_df %>% 
  filter(., item %in% critical_items) %>% View







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
map(.x = children_carrier, .f = read_csv) %>% 
  bind_rows(.) %>% 
  separate(., col = Filename, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x) %>% 
  write_csv(., path = here("data", "dataframes", "raw", "carrier_raw.csv"))

# Load raw csv file
car_df <- read_csv(here("data", "dataframes", "raw", "./carrier_raw.csv"))

# Check it
head(car_df)

