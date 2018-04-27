source(here::here("./rScripts/03_load_data.R"))


# Syllabification task ---------------------------------------------------------
syllabified_props <- xtabs(~ participant + response, data = syllabified_trip) %>% 
  as.tibble(.) %>% 
  arrange(., participant) %>% 
  mutate(., prop = n / 14, 
            response_simp = if_else(response == 'Tripthong', 
                                    'Tripthong', 'Hiatus/\nSimplification')) 

hls_syllabification_p1 <- syllabified_props %>% 
  group_by(., response) %>% 
  summarize(., count = sum(n)) %>% 
  ungroup(.) %>% 
  mutate(., prop = count / sum(count)) %>% 
  ggplot(., aes(x = response, y = prop, fill = response)) + 
    geom_bar(stat = 'identity', width = 0.3, show.legend = F, color = 'grey20') + 
    ylim(0, 1) + 
    scale_fill_grey(start = 0.45, end = 0.75) + 
    stat_summary(data = syllabified_props, aes(x = response, y = prop),
                 fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1.25, fill = 'white', color = 'grey30') + 
    labs(y = 'Proportion', x = 'Response', caption = 'Mean +/- SE') +
    theme_test(base_size = 16, base_family = 'Times') 



simp_props <- syllabified_props %>% 
  group_by(., participant, response_simp) %>% 
  summarize(., count = sum(n)) %>% 
  mutate(., prop = count / sum(count)) %>% 
  ungroup(.) 

hls_syllabification_p2 <- simp_props %>% 
  group_by(., response_simp) %>% 
  summarize(., count = sum(count)) %>% 
  ungroup(.) %>% 
  mutate(., prop = count / sum(count)) %>%
  ggplot(., aes(x = response_simp, y = prop, fill = response_simp)) + 
    geom_bar(stat = 'identity', width = 0.3, show.legend = F, color = 'grey20') + 
    ylim(0, 1) + 
    scale_fill_grey(start = 0.45, end = 0.75) + 
    stat_summary(data = simp_props, aes(x = response_simp, y = prop),
                 fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1.25, fill = 'white', color = 'grey30') + 
    labs(y = 'Proportion', x = 'Response', caption = 'Mean +/- SE') +
    theme_test(base_size = 16, base_family = 'Times')









# Carrier task -----------------------------------------------------------------

# Get critical items
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

# Target words in part two
critical_items_palatals <- c(
#    [tʃ]          [j]        [ɲ]                     
  "chiaba",     "lliape",  "manhiala",    # ia
  "mebochiana",            "costonhialo", # ia, minus "ruyiola"
  "pachialo",              "nhiape"       # ia, minus "payielo",
)

comparison_items_nonpalatals <- c(
#     [ia]
 'falufialo', # [f]
 'falukiago', # [k]
 'liamo',     # [l]
 'piano'      # [p]
)


hls_carrier_dur_p1 <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals)) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 'palatal', 'other')) %>% 
  ggplot(., aes(x = is_palatal, y = duration, color = is_palatal)) + 
    stat_summary(fun.data = mean_se, geom = 'pointrange') 

hls_carrier_f1_p2 <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals)) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  group_by(., participant, TextGridLabel) %>% 
  mutate(., f1norm = (f1 - mean(f1)) / sd(f1), 
            f2norm = (f2 - mean(f2)) / sd(f2)) %>% 
  ungroup(.) %>% 
  ggplot(., aes(x = time_course_segment, y = f1norm, color = is_palatal)) + 
    stat_summary(fun.data = mean_se, geom = 'pointrange') + 
    stat_summary(fun.y = mean, geom = 'line') + 
    scale_y_reverse()

hls_carrier_int_p3 <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals)) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  ggplot(., aes(x = time_course_segment, y = `in`, color = is_palatal)) + 
    stat_summary(fun.data = mean_se, geom = 'pointrange') + 
    stat_summary(fun.y = mean, geom = 'line') 



