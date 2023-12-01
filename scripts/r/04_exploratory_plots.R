source(here::here("./scripts/r/03_load_data.R"))


# Syllabification task subsets -------------------------------------------------
#
# Props as a function of 3 response types for each participant

# remove labials delante de [w]
labial_remove <- c("lakabuaisto", "lakafuaisto", "lakapuaisto")

syllabified_props <- syllabified_trip %>% 
  filter(., !(item %in% labial_remove)) %>% 
  xtabs(~ participant + response, data = .) %>% 
  as_tibble(.) %>% 
  arrange(., participant) %>% 
  mutate(., prop = n / 11, # switch to 11 if you use 'labial_remove'
            response_simp = if_else(response == 'Tripthong', 
                                    'Triphthong', 'Hiatus/\nSimplification'), 
            response = fct_recode(response, "Triphthong" = "Tripthong")) 

# Props as a function of 2 response types for each participant
simp_props <- syllabified_props %>% 
  group_by(., participant, response_simp) %>% 
  summarize(., count = sum(n), .groups = "drop") %>% 
  group_by(participant) %>% 
  mutate(., prop = count / sum(count)) %>% 
  ungroup(.) 


# Syllabification task plots ---------------------------------------------------
#
# Response proportion as a function of response type
hls_syllabification_p1 <- syllabified_props %>% 
  group_by(., response) %>% 
  summarize(., count = sum(n)) %>% 
  ungroup(.) %>% 
  mutate(., prop = count / sum(count)) %>% 
  ggplot(., aes(x = response, y = prop, fill = response)) + 
    geom_bar(stat = 'identity', width = 0.3, show.legend = F, color = 'grey20') + 
    ylim(0, 1) + 
    scale_fill_brewer(palette = "Set1") + 
    stat_summary(data = syllabified_props, aes(x = response, y = prop),
                 fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1.25, fill = 'white', color = 'grey30') + 
    labs(y = 'Proportion  ', x = '', caption = 'Mean +/- SE', 
         title = "Syllabification task", 
         subtitle = "Proportion of responses across all data") +
    my_theme() +
    # my_save("figs/plot_syllabification_all.png") + 
    NULL

# Response proportion as a function of response type simplified
hls_syllabification_p2 <- simp_props %>% 
  group_by(., response_simp) %>% 
  summarize(., count = sum(count)) %>% 
  ungroup(.) %>% 
  mutate(., prop = count / sum(count)) %>%
  ggplot(., aes(x = response_simp, y = prop, fill = response_simp)) + 
    geom_bar(stat = 'identity', width = 0.3, show.legend = F, color = 'grey20') + 
    ylim(0, 1) + 
    scale_fill_brewer(palette = "Set1") + 
    stat_summary(data = simp_props, aes(x = response_simp, y = prop),
                 fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1.25, fill = 'white', color = 'grey30') + 
    labs(y = 'Proportion', x = '', caption = 'Mean +/- SE', 
         title = "Syllabification task", 
         subtitle = "Proportion of responses across all data") +
    my_theme() + 
    # my_save("figs/plot_syllabification_combined.png") + 
    NULL


hls_syllabification_all_p3 <- syllabified_trip %>% 
  ggplot(., aes(x = glide, y = as.numeric(as.factor(response)) - 1, 
                color = pre_c_voicing, shape = pre_c_poa)) + 
    geom_jitter(width = 0.2, height = 0.2, size = 2) + 
    scale_y_continuous(breaks = 0:2, name = 'Response', 
                       labels = c('Hiatus', 'Simplification', 'Triphthong')) + 
    scale_x_discrete(name = 'Glide', labels = c('[j]', '[w]')) + 
    scale_color_brewer(name = 'Voicing', labels = c('Voiced', 'Voiceless'), 
                       palette = 'Set1') + 
    scale_shape_discrete(name = 'Preceding\nconsonant\nPOA', 
                         labels = c('Bilabial', 'Dental', 'Labiodental', 'Velar')) + 
    my_theme() + 
    # my_save("figs/plot_syllabification_by_glide_cons_voicing.png") + 
    NULL














# Carrier task -----------------------------------------------------------------

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

if(F) {
carrier_tc_final <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i') %>% 
  mutate(., pre_c = if_else(item %in% comparison_items_nonpalatals, 'other', 
                            if_else(item %in% c('chiaba', 'mebochiana', 'pachialo'), 'ch', 
                                    if_else(item == 'lliape', 'j', 'nh')))) 
}

hls_carrier_dur_p1 <- carrier_tc_final %>% 
  filter(., duration <= 375) %>% 
  group_by(., participant, item, is_palatal) %>% 
  summarize(., dur = mean(duration), .groups = "drop") %>% 
  ungroup(.) %>% 
  ggplot(., aes(x = is_palatal, y = dur, fill = is_palatal)) + 
    geom_jitter(alpha = 0.2, height = 0, width = 0.2) + 
    stat_summary(fun.data = mean_cl_boot, geom = 'pointrange', 
                 pch = 21, color = 'black', size = 1.25, show.legend = F) + 
    labs(y = "Duration (ms)", x = "", 
         caption = "Mean +/- 95% CI", title = "Phrase reading", 
         subtitle = "Duration of pre-vocalic glide after palatal and non-palatal onset") + 
    scale_fill_brewer(palette = "Set1") + 
    scale_x_discrete(labels = c('Other', 'Palatal')) + 
    my_theme() + 
    #my_save("figs/plot_phrase_duration.png") + 
    NULL


hls_carrier_f1_p2 <- carrier_tc_final %>% 
  filter(., time_course_segment != 0) %>% 
  ggplot(., aes(x = time_course_segment, y = f1norm, fill = is_palatal)) + 
    stat_summary(aes(color = is_palatal), fun = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, color = 'grey20', size = 1) + 
    scale_y_reverse() + 
    scale_fill_brewer(name = "Preceding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    scale_color_brewer(palette = "Set1", guide = "none") + 
    labs(y = "Normalized F1", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.8))

hls_carrier_f1_p3 <- carrier_tc_final %>% 
  filter(., time_course_segment != 0) %>% 
  ggplot(., aes(x = time_course_segment, y = f1norm, fill = pre_c)) + 
    stat_summary(aes(color = pre_c), fun = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, color = 'grey20', size = 1) + 
    scale_y_reverse() + 
    scale_fill_brewer(name = "Preceding\nconsonant", palette = 'Set1', 
                      labels = c("ch", "j", "nh", "other")) + 
    scale_color_brewer(palette = "Set1", guide = "none") + 
    labs(y = "Normalized F1", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.8))




hls_carrier_int_p4 <- carrier_tc_final %>% 
  ggplot(., aes(x = time_course_segment, y = `in`, fill = is_palatal)) + 
    stat_summary(aes(color = is_palatal), fun = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1, color = 'grey20') + 
    scale_fill_brewer(name = "Preceding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    scale_color_brewer(palette = "Set1", guide = "none") + 
    labs(y = "Intensity (dB)", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.15))

hls_carrier_int_p5 <- carrier_tc_final %>% 
  ggplot(., aes(x = time_course_segment, y = `in`, fill = pre_c)) + 
    stat_summary(aes(color = pre_c), fun = mean, geom = 'line') + 
    stat_summary(fun.data = mean_se, geom = 'pointrange', 
                 pch = 21, size = 1, color = 'grey20') + 
    scale_fill_brewer(name = "Preceding\nconsonant", palette = 'Set1', 
                      labels = c("ch", "j", "nh", "other")) + 
    scale_color_brewer(palette = "Set1", guide = "none") + 
    labs(y = "Intensity (dB)", x = "% Time course of [j]", 
         caption = "Mean +/- SE") + 
    theme_test(base_size = 16, base_family = 'Times') 


int_dur <- carrier_tc_final %>% 
  filter(., time_course_segment %in% c(0, 100), 
            duration <= 375) %>% 
  select(., participant:sex, int = `in`, is_palatal) %>% 
  spread(., time_course_segment, int) %>% 
  mutate(., int_diff = `100` - `0`)

int_dur_means <- int_dur %>% 
  group_by(is_palatal) %>% 
  summarise(., int_mean = mean(int_diff), dur_mean = mean(duration))

hls_carrier_scatter_p6 <- int_dur %>% 
  ggplot(., aes(x = duration, y = int_diff, color = is_palatal)) + 
    geom_point(size = 4, alpha = 0.9, pch = 21, fill = 'grey90', stroke = 1) + 
    geom_point(data = int_dur_means, aes(x = dur_mean, y = int_mean), 
               size = 8, pch = 21, stroke = 2, show.legend = F) + 
    scale_color_brewer(name = "Preceding\nconsonant", palette = 'Set1', 
                      labels = c("Other", "Palatal")) + 
    labs(y = "Intensity difference (dB)", x = "Duration of [j] (ms)") + 
    theme_test(base_size = 16, base_family = 'Times') + 
    theme(legend.position = c(0.9, 0.15))
