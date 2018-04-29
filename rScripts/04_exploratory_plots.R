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
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i') %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  ggplot(., aes(x = is_palatal, y = duration, fill = is_palatal)) + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, color = 'black', size = 1.25, show.legend = F) + 
    #coord_cartesian(ylim = c(100, 130)) + 
    labs(y = "Duration (ms)", x = "Preceeding consonant", 
         caption = "Mean +/- SE") + 
    scale_fill_brewer(palette = "Set1") + 
    scale_x_discrete(labels = c('Other', 'Palatal')) + 
    theme_test(base_size = 16, base_family = 'Times') 


hls_carrier_f1_p2 <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i', time_course_segment != 0) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  group_by(., participant, TextGridLabel) %>% 
  mutate(., f1norm = (f1 - mean(f1)) / sd(f1), 
            f2norm = (f2 - mean(f2)) / sd(f2)) %>% 
  ungroup(.) %>% 
  ggplot(., aes(x = time_course_segment, y = f1norm, fill = is_palatal)) + 
    stat_summary(aes(color = is_palatal), fun.y = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, color = 'grey20', size = 1) + 
    scale_y_reverse() + 
    scale_fill_brewer(name = "Preceeding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    scale_color_brewer(palette = "Set1", guide = F) + 
    labs(y = "Normalized F1", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.8))


hls_carrier_int_p3 <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i') %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  ggplot(., aes(x = time_course_segment, y = `in`, fill = is_palatal)) + 
    stat_summary(aes(color = is_palatal), fun.y = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1, color = 'grey20') + 
    scale_fill_brewer(name = "Preceeding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    scale_color_brewer(palette = "Set1", guide = F) + 
    labs(y = "Intensity (dB)", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.15))



int_dur <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i', 
            time_course_segment %in% c(0, 100)) %>% 
  mutate(., is_palatal = if_else(item %in% critical_items_palatals, 
                                 'palatal', 'other')) %>% 
  select(., participant:sex, int = `in`, is_palatal) %>% 
  spread(., time_course_segment, int) %>% 
  mutate(., int_diff = `100` - `0`) 

int_dur_means <- int_dur %>% 
  group_by(is_palatal) %>% 
  summarise(., int_mean = mean(int_diff), dur_mean = mean(duration))

hls_carrier_scatter_p4 <- int_dur %>% 
  ggplot(., aes(x = duration, y = int_diff, color = is_palatal)) + 
    geom_point(size = 4, alpha = 0.9, pch = 21, fill = 'grey90', stroke = 1) + 
    geom_point(data = int_dur_means, aes(x = dur_mean, y = int_mean), 
               size = 8, pch = 21, stroke = 2, show.legend = F) + 
    scale_color_brewer(name = "Preceeding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    labs(y = "Intensity difference (dB)", x = "Duration of [j] (ms)") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.15))
