# Carrier analyses ------------------------------------------------------------
#
# What are my questions?
#
# 1. Does duration vary as a function of preceding consonant?
# 2. Does the time course of F1 or intensity vary as a function of preceding 
#    consonant?
# How can I answer them?
# 1. linear mixed effects (dur ~ env)
# 2. gam (int ~ time course)
#
# -----------------------------------------------------------------------------



# Setup -----------------------------------------------------------------------

# Source helpers and load data
source(here::here("scripts", "r", "03_load_data.R"))

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

carrier_tc_final <- carrier_tc %>% 
  filter(., item %in% c(critical_items_palatals, 
                        comparison_items_nonpalatals), 
            TextGridLabel == 'i') %>% 
  mutate(., pre_c = if_else(item %in% comparison_items_nonpalatals, 'other', 
                            if_else(item %in% c('chiaba', 'mebochiana', 'pachialo'), 'ch', 
                                    if_else(item == 'lliape', 'j', 'nh')))) %>% 
  write_csv(., "./data/dataframes/tidy/carrier_timecourse_subset_tidy.csv")

carrier_dur_final <- carrier_tc_final %>% 
  group_by(., participant, item, is_palatal) %>% 
  summarize(., dur = mean(duration), .groups = "drop") %>% 
  ungroup(.) %>% 
  mutate(dur_std = (dur - mean(dur)) / sd(dur), 
         palatal_sum = if_else(is_palatal == "palatal", 1, -1)) %>% 
  write_csv(., "./data/dataframes/tidy/carrier_duration_subset_tidy.csv")

# -----------------------------------------------------------------------------



# Duration analysis -----------------------------------------------------------

dur_mod_formula <- 
  brmsformula(dur_std ~ palatal_sum + 
       (1 + palatal_sum | participant) + 
       (1 | item))

b_dur_mod <- brm(
  formula = dur_mod_formula, 
  chains = 4, iter = 2000, warmup = 1000, cores = 4, 
  data = carrier_dur_final, 
  control = list(adapt_delta = 0.99), 
  backend = "cmdstanr", 
  prior = c(
    prior(normal(0, 0.5), class = Intercept), 
    prior(normal(0, 1), class = b), 
    prior(cauchy(0, 1), class = sd), 
    prior(lkj(2), class = cor)
  ), 
  file = here("models", "b_dur_mod")
)

post_dur <- posterior_samples(b_dur_mod) %>% 
  select(starts_with("b_")) %>% 
  transmute(
    palatal = b_Intercept + b_palatal_sum, 
    other = b_Intercept - b_palatal_sum, 
    diff = palatal - other
  ) 

p_dur_param <- post_dur %>% 
  select(-diff) %>% 
  pivot_longer(cols = everything(), names_to = "param", values_to = "estimate") %>% 
  mutate(param = str_to_title(param)) %>% 
  ggplot(., aes(x = estimate, fill = param, color = param)) + 
    stat_slab(alpha = 0.5, color = "white") +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .3, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    labs(y = NULL, x = expression(paste(beta, "-Duration (std.)"))) + 
    coord_cartesian(ylim = c(-0.1, NA)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(legend.position = c(0.1, 0.85), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_dur_diff <- post_dur %>% 
  ggplot(., aes(x = diff)) + 
    stat_slab(alpha = 0.5, color = "white", fill = my_colors[2]) +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .3, preserve = "single"), 
      color = my_colors[2], show.legend = F) +
    labs(y = NULL, x = expression(paste(beta, "-Palatal − Other"))) + 
    coord_cartesian(ylim = c(-0.1, NA)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

p_dur_param + p_dur_diff + plot_annotation(tag_levels = 'A')

# -----------------------------------------------------------------------------







# Time course of [j]: ---------------------------------------------------------

# set participant to factor
# set modality to ordered variable and relevel so production is reference
carrier_tc_final_gamm <- carrier_tc_final %>% 
  mutate(
    participant = as.factor(participant), 
    is_palatal_ord = as.ordered(is_palatal), 
    is_palatal_ord = fct_relevel(is_palatal_ord, 'palatal'), 
    int_norm = (`in` - mean(`in`)) / sd(`in`), 
    palatal_sum = if_else(is_palatal == "palatal", 1, -1))

# dummy code is_palatal_ord
contrasts(carrier_tc_final_gamm$is_palatal_ord) <- "contr.treatment" 



f1_bam_1 <- brm(
  formula = f1norm ~ is_palatal + 
    s(time_course_segment, bs = "cr", k = 3) +                  # reference smooth
    s(time_course_segment, by = is_palatal, bs = "cr", k = 3) + # difference smooth
    s(time_course_segment, participant, bs = "fs", m = 1, k = 3), # random 
  family = gaussian(), 
  prior = c(
    prior(normal(0, 5), class = Intercept), 
    prior(normal(0, 5), class = b), 
    prior(student_t(3, 0, 2.5), class = sds), 
    prior(cauchy(0, 2), class = sigma)
  ), 
  backend = "cmdstanr", iter = 2000, warmup = 1000, cores = 4,
  control = list(adapt_delta = 0.9999, max_treedepth = 20), 
  data = carrier_tc_final_gamm
  ) 

int_bam_1 <- brm(
  formula = int_norm ~ is_palatal + 
    s(time_course_segment, bs = "cr", k = 3) +                  # reference smooth
    s(time_course_segment, by = is_palatal, bs = "cr", k = 3) + # difference smooth
    s(time_course_segment, participant, bs = "fs", m = 1, k = 3), # random 
  family = gaussian(), 
  prior = c(
    prior(normal(0, 5), class = Intercept), 
    prior(normal(0, 5), class = b), 
    prior(student_t(3, 0, 2.5), class = sds), 
    prior(cauchy(0, 2), class = sigma)
  ), 
  backend = "cmdstanr", iter = 2000, warmup = 1000, cores = 4,
  control = list(adapt_delta = 0.9999, max_treedepth = 20), 
  data = carrier_tc_final_gamm
  ) 




grid <- carrier_tc_final_gamm %>%
  data_grid(is_palatal, time_course_segment, participant)

grid %>% 
  add_epred_draws(f1_bam_1, ndraws = 300, re_formula = NULL) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = .epred)) + 
    geom_line(aes(group = interaction(time_course_segment, participant, .draw), 
      color = is_palatal), alpha = 0.1, size = 0.25) +
    #stat_summary(aes(group = is_palatal), fun = mean, geom = "line", 
    #  size = 7, color = "white") + 
    #stat_summary(aes(color = is_palatal), fun = mean, geom = "line", 
    #  size = 2.5) + 
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    labs(y = "z-F1", x = "") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12)


p_f1_tc <- plot(conditional_effects(f1_bam_1, 
  spaghetti = T, nsamples = 500), plot = F, 
  line_args = list(size = 1.75))[[3]] + 
  scale_color_manual(name = NULL, values = alpha(my_colors[c(1, 3)], 0.1)) + 
  scale_x_continuous(labels = c("0%", "25%", "50%", "75%", "100%"), 
    expand = expansion(mult = c(0, 0)), limits = c(-2, 102)) + 
  labs(y = "z-F1", x = "") + 
  ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12) + 
  theme(legend.position = c(0.1, 0.9))

p_f1_tc_diff <- grid %>%
  add_epred_draws(f1_bam_1, re_formula = NA, ndraws = 300) %>% 
  ungroup() %>% 
  select(participant, is_palatal, time_course_segment, .epred) %>% 
  group_by(participant, is_palatal) %>% 
  mutate(row = row_number()) %>% 
  pivot_wider(names_from = "is_palatal", values_from = ".epred") %>% 
  mutate(diff =  palatal - other) %>% 
  group_by(time_course_segment) %>% 
  mutate(dist = seq_along(time_course_segment)) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = diff)) + 
    geom_hline(yintercept = 0, lty = 3) + 
    geom_line(aes(group = dist), color = "lightgrey", alpha = 0.1, size = 0.25) + 
    stat_summary(fun = mean, geom = "line", size = 7, color = "white") + 
    stat_summary(fun = mean, geom = "line", size = 2.5, color = my_colors[2]) + 
    stat_pointinterval(.width = c(.66, .95), pch = 21, point_fill = "white") + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    labs(y = "z-F1 difference\nPalatal - Other", x = "Time course") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12)

p_f1_tc + p_f1_tc_diff



p_int_tc <- plot(conditional_effects(int_bam_1, 
  spaghetti = T, nsamples = 500), plot = F)[[3]] + 
  scale_color_viridis_d(name = NULL, option = "B", end = 0.8, alpha = 0.1) + 
  scale_x_continuous(labels = c("0%", "25%", "50%", "75%", "100%"), 
    expand = expansion(mult = c(0, 0)), limits = c(-2, 102)) + 
  labs(y = "Intensity (dB)", x = "") + 
  ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12) + 
  theme(legend.position = c(0.1, 0.9))

p_int_tc_diff <- grid %>%
  add_epred_draws(int_bam_1, re_formula = NA, ndraws = 300) %>% 
  ungroup() %>% 
  select(participant, is_palatal, time_course_segment, .epred) %>% 
  group_by(participant, is_palatal) %>% 
  mutate(row = row_number()) %>% 
  pivot_wider(names_from = "is_palatal", values_from = ".epred") %>% 
  mutate(diff =  palatal - other) %>% 
  group_by(time_course_segment) %>% 
  mutate(dist = seq_along(time_course_segment)) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = diff)) + 
    geom_hline(yintercept = 0, lty = 3) + 
    geom_line(aes(group = dist), color = "lightgrey", alpha = 0.1, size = 0.25) + 
    stat_summary(fun = mean, geom = "line", size = 7, color = "white") + 
    stat_summary(fun = mean, geom = "line", size = 2.5, color = "darkred") + 
    stat_pointinterval(.width = c(.66, .95), pch = 21, point_fill = "white") + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    labs(y = "Intensity difference (dB)\nPalatal - Other", x = "Time course") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12)

p_int_tc + p_int_tc_diff
