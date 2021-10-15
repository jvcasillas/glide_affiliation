source(here::here("./scripts/r/00_helpers.R"))


# Load syllabification data ----------------------------------------------------
syl_df <- read_csv(here("data", "dataframes", "raw", "./syllable_raw.csv"))


# Tidy data --------------------------------------------------------------------
#
# labID coding: 
#  - extra = hiato
#  - error = simplification or wrong vowel
#  - NA = triphthong


# Get critical items
critical_items_triphthongs <- c(
#      [j]            [w]
  "lakabiaisto", "lakabuaisto", # [b]
  "lakadiaisto", "lakaduaisto", # [d]
  "lakafiaisto", "lakafuaisto", # [f]
  "lakagiaisto", "lakaguaisto", # [g]
  "lakakiaisto", "lakakuaisto", # [k]
  "lakapiaisto", "lakapuaisto", # [p]
  "lakatiaisto", "lakatuaisto"  # [t]
)

critical_syllables <- c(
#   [j]      [w]
  "biais", "buais", # [b]
  "diais", "duais", # [d]
  "fiais", "fuais", # [f]
  "giais", "guais", # [g]
  "kiais", "kuais", # [k]
  "piais", "puais", # [p]
  "tiais", "tuais"  # [t]
)

# Create appropriate columns from file names
# Remove extraneous columns
# Filter to keep critical items
# Create 'response' column with three possible responses: 
#  - hiato
#  - triphthong
#  - simplification
# if_else series to fill 'response' column
syl_tidy <- syl_df %>% 
  separate(., col = prefix, 
              into = c('participant', 'exp', 'task', 'item', 'status')) %>% 
  select(., -ends_with('Dur'), -critOnsetLab) %>% 
  filter(., item %in% critical_items_triphthongs) %>% 
  mutate(., itemRepeat = item, 
            response = if_else(syll3Lab %in% critical_syllables, 'Triphthong', 
                               if_else(!(syll3Lab %in% critical_syllables) & 
                                         labID == 'extra', 'Hiatus', 'Simplification')), 
            response = if_else(is.na(response), 'Simplification', response), 
            item = as.factor(item), 
            response = as.factor(response)) %>% 
  separate(., col = itemRepeat, into = c('fluff1', 'glide', 'fluff2'), 
              remove = T, sep = c(4, 6)) %>% 
  select(-c(fluff1, fluff2)) %>% 
  separate(., col = glide, into = c('pre_c', 'glide'), sep = 1, remove = T) %>% 
  mutate(., pre_c_voicing = if_else(pre_c %in% c('b', 'd', 'g'), 'voiced', 'voiceless'), 
            pre_c_poa = if_else(pre_c %in% c('b', 'p'), 'bilabial', 
                                if_else(pre_c %in% c('d', 't'), 'dental', 
                                        if_else(pre_c == 'f', 'labiodental', 'velar')))) %>% 
  select(., participant:status, 
            critical_syllable = syll3Lab, 
            pre_c, 
            pre_c_voicing, 
            pre_c_poa, 
            glide, 
            response) %>% 
  write_csv(., file = here("data", "dataframes", "tidy", "syllabified_triphthong_tidy.csv"))
