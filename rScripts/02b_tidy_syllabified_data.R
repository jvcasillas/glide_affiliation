source(here::here("./rScripts/00_helpers.R"))


# Load new file
syl_df <- read_csv(here("data", "dataframes", "raw", "./syllable_raw.csv")) %>% 
  separate(., col = prefix, 
              into = c('participant', 'exp', 'x', 'item', 'status')) %>% 
  select(-x)

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
