source(here::here("./rScripts/03_load_data.R"))

xtabs(~ item + response, data = syllabified_trip)

ggplot(syllabified_trip, aes(x = item, y = response)) + 
  geom_jitter()
