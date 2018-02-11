
syl_df <- read_csv(here("data", "tidy", "./syllable_clean.csv"))

glimpse(syl_df)

syl_df %>%
  ggplot(., aes(x = syll1Dur, y = syll2Dur, label = item)) + 
    geom_text() + 
    geom_smooth(method = 'lm')
