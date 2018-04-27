source(here::here("./rScripts/00_helpers.R"))


# Load syllabification data ----------------------------------------------------
syl_df <- read_csv(here("data", "dataframes", "raw", "./syllable_raw.csv"))


# Tidy data --------------------------------------------------------------------
#
# labID coding: 
#  - extra = hiato
#  - error = simplification or wrong vowel
#  - NA = tripthong


# Get critical items
critical_items <- c(
  "lakabiaisto", "lakabuaisto", 
  "lakadiaisto", "lakaduaisto", 
  "lakafiaisto", "lakafuaisto", 
  "lakagiaisto", "lakaguaisto", 
  "lakakiaisto", "lakakuaisto", 
  "lakapiaisto", "lakapuaisto", 
  "lakatiaisto", "lakatuaisto"
)

critical_syllables <- c(
  "biais", "buais", 
  "diais", "duais", 
  "fiais", "fuais", 
  "giais", "guais", 
  "kiais", "kuais", 
  "piais", "puais", 
  "tiais", "tuais"
)

# Create appropriate columns from file names
# Remove extraneous columns
# Filter to keep critical items
# Create 'response' column with three possible responses: 
#  - hiato
#  - tripthong
#  - simplification
# if_else series to fill 'response' column
syl_tidy <- syl_df %>% 
  separate(., col = prefix, 
              into = c('participant', 'exp', 'task', 'item', 'status')) %>% 
  select(., -ends_with('Dur'), -critOnsetLab) %>% 
  filter( item %in% critical_items) %>% 
  mutate(., response = if_else(syll3Lab %in% critical_syllables, 'Tripthong', 
                               if_else(!(syll3Lab %in% critical_syllables) & 
                                         labID == 'extra', 'Hiatus', 'Simplification')), 
            response = if_else(is.na(response), 'Simplification', response), 
            item = as.factor(item), 
            response = as.factor(response)) %>% 
  write_csv(., path = here("data", "dataframes", "tidy", "syllabified_tripthong_tidy.csv"))





