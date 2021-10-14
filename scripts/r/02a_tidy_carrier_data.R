source(here::here("./scripts/r/00_helpers.R"))

# Load raw csv file ------------------------------------------------------------
car_df <- read_csv(here("data", "dataframes", "raw", "./carrier_raw.csv")) 



# Setup ------------------------------------------------------------------------

# Get critical items for subsetting and creating new variables
critical_items_tripthongs <- c(
#      [j]            [w]
  "lakabiaisto", "lakabuaisto", # [b]
  "lakadiaisto", "lakaduaisto", # [d]
  "lakafiaisto", "lakafuaisto", # [f]
  "lakagiaisto", "lakaguaisto", # [g]
  "lakakiaisto", "lakakuaisto", # [k]
  "lakapiaisto", "lakapuaisto", # [p]
  "lakatiaisto", "lakatuaisto"  # [t]
)

# Target words in part two of carrier task
critical_items_palatals <- c(
#    [tʃ]          [j]        [ɲ]                     
  "chiaba",     "lliape",  "manhiala",    # ia
  "mebochiana",            "costonhialo", # ia, minus "ruyiola"
  "pachialo",              "nhiape"       # ia, minus "payielo",
)

# Words to compare with critical items
comparison_items_nonpalatals <- c(
#     [ia]
 'falufialo', # [f]
 'falukiago', # [k]
 'liamo',     # [l]
 'piano'      # [p]
)





# Tidy time course data --------------------------------------------------------
#
# Create columns for 'participant', 'exp', 'task', 'item' and 'status' from 
# file name. 
# Filter out misses and errors. 
# Gather -> separate -> spread to create time course. 
# Make duration more interpretable, round all continuous variables to two 
# decimal places, and save as tidy .csv file
car_timecourse <- car_df %>%
  separate(., col = Filename, 
              into = c('participant', 'exp', 'task', 'item', 'status')) %>% 
  filter(., status == 'hit', TextGridLabel != "error") %>% 
  gather(., metric, value, 
         -c(participant, exp, task, item, status, TextGridLabel, duration)) %>% 
  separate(., metric, into = c('metric', 'time_course_segment'), sep = "_") %>% 
  mutate(., time_course_segment = as.numeric(time_course_segment), 
            duration = (duration * 1000) %>% round(., 2), 
            value = round(value, 2), 
            sex = if_else(participant %in% c('p03', 'p04', 'p07'), 'm', 'f')) %>% 
  spread(., metric, value) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  group_by(., participant, TextGridLabel) %>% 
  mutate(., f1norm = (f1 - mean(f1)) / sd(f1), 
            f2norm = (f2 - mean(f2)) / sd(f2)) %>% 
  ungroup(.) %>% 
  write_csv(., path = here("data", "dataframes", "tidy", "carrier_timecourse_tidy.csv"))









# tidy duration data -----------------------------------------------------------
#
# Create columns for 'participant', 'exp', 'task', 'item' and 'status' from 
# file name. 
# Remove unnecessary columns. 
# Filter out misses and errors. 
# Make duration more interpretable, round to two digits, and save as tidy .csv
car_duration <- car_df %>%
  separate(., col = Filename, 
              into = c('participant', 'exp', 'task', 'item', 'status')) %>% 
  select(participant:duration) %>% 
  filter(., status == 'hit', TextGridLabel != "error") %>% 
  mutate(., duration = (duration * 1000) %>% round(., 2), 
            sex = if_else(participant %in% c('p03', 'p04', 'p07'), 'm', 'f')) %>% 
  write_csv(., path = here("data", "dataframes", "tidy", "carrier_duration_tidy.csv"))








