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

# -----------------------------------------------------------------------------
# 02122025
# Table for Phase_2
view(phase_2)


# create rule for aligning Participant's response with Phase 1
phase_2_match <- phase_2 %>%
  mutate(match = common_response == response) %>%
  drop_na(match) %>%
  arrange(item) %>%
  group_by(item)

#subset with only diphthongs. Returns rows where op3 is NA

phase_2_diphthong <- phase_2_match %>%
  filter(is.na(op3)) %>%
  mutate(match = common_response == response,
  matched_option = case_when(
    response == op1~"diphthong",
    response == op2~"hiatus",
    TRUE ~"No Match"))

  
print(phase_2_diphthong)
table(phase_2_diphthong$match)

#
# FALSE  TRUE 
# 2202  3886 

## responses matched the diphthong, the hiatus or response was altered by participant

cbPalette <- c("#000000","#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

#distribution of responses

phase_2_diphthong %>%
  count(match,matched_option) %>%
  mutate(match = factor(match, levels = c("TRUE", "FALSE"))) %>%
  ggplot(aes(x = match, y = n, fill = match)) +
  stat_summary(fun="identity", geom = "bar", position= "dodge")+
  geom_col() +
  facet_wrap(~matched_option, scales = "free_x") +
  labs(x = "Phase 2 = phase 1 response?", y = "count") +
  theme(legend.position = "none") +
  scale_color_manual(values=cbPalette[c(3,4)]) +
  scale_fill_manual(values=cbPalette[c(3,4)]) +
  my_save("Phase2_Feb25/plot_response_diphthongs.png")


#subset with only triphthongs. Keeps only rows where op3 is NOT na

phase_2_triphthong <- phase_2_match %>%
  filter(!is.na(op3)) %>%
  mutate(match = common_response == response,
         matched_option = case_when(
           response == op1~"triphthong",
           response == op2~"FallingDiphthong",
           response == op3~"RisingDiphthong",
           TRUE ~"No Match")
  )

print(phase_2_triphthong)
#subset with only diphthongs

table(phase_2_diphthong$match)

#
#FALSE  TRUE 
#4074  6277 
## responses matched the triphthong, falling diphthong, rising diphthong or response was altered by participant


#distribution of responses

phase_2_triphthong %>%
  count(match,matched_option) %>%
  mutate(match = factor(match, levels = c("TRUE", "FALSE"))) %>%
  ggplot(aes(x = match, y = n, fill = match)) +
  stat_summary(fun="identity", geom = "bar", position= "dodge")+
  geom_col() +
  facet_wrap(~matched_option, scales = "free_x") +
  labs(x = "Phase 2 = phase 1 response?", y = "count") +
  theme(legend.position = "none") +
  scale_color_manual(values=cbPalette[c(3,4)]) +
  scale_fill_manual(values=cbPalette[c(3,4)]) +
  my_save("Phase2_Feb25/plot_response_triphthongs.png")


## order by item

phase_2_f <- phase_2 %>%
  mutate(match = common_response == response) %>%
  drop_na(match) %>%
  arrange(item) %>%
  group_by(item) %>%
  filter(match == "FALSE")


## exploring non-matches by items

phase_2_f %>%
  group_by(match, item) %>%
  count(match) %>%
  ggplot(aes(x=reorder(item,n), y=n, fill = n)) +
  geom_col() +
  coord_flip() +
  xlab("item") +
  scale_fill_gradient(low = "#009E73", high = "#CC79A7") +
  my_save("Phase2_Feb25/plot_response_mismatches.png")
