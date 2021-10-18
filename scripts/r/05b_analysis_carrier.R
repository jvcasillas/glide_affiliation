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

post_dur <- as_draws_df(b_dur_mod) %>% 
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
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .3, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    labs(y = NULL, x = "Duration (std.)") + 
    annotate("text", label = "(A)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(legend.position = c(0.15, 0.75), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_dur_diff <- post_dur %>% 
  ggplot(., aes(x = diff)) + 
    stat_slab(alpha = 0.7, color = "white", fill = my_colors[2]) +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .3, preserve = "single"), 
      color = my_colors[2], show.legend = F) +
    labs(y = NULL, x = "Duration difference") + 
    annotate("text", label = "(B)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

duration_all <- p_dur_param + p_dur_diff

ggsave(
  filename = "duration_all.png", 
  plot = duration_all, 
  path = here("figs", "manuscript"), width = 7, height = 3.5, dpi = 600
  )

# Duration mod table
dur_tab_dat <- as_draws_df(b_dur_mod) %>% 
  select(starts_with(c("b_", "sd_", "cor_p", "sigma"))) %>% 
  pivot_longer(cols = everything()) %>% 
  mutate(type = case_when(
    startsWith(name, "b_") ~ "Population", 
    TRUE ~ "Grouping"), 
    type = fct_relevel(type, "Population")) %>% 
  mutate(
    name = str_remove_all(name, "b_"), 
    name = str_replace_all(name, "sd_", "σ "), 
    name = str_replace(name, "sigma", "Residual σ"), 
    name = str_replace(name, "cor_participant__Intercept__", 
      "Cor. Participant:\nInt., "), 
    name = str_replace_all(name, "__", ":\n"), 
    name = str_replace_all(name, "palatal_sum", "Palatal"), 
    name = str_replace_all(name, "participant", "Participant"), 
    name = str_replace(name, "item", "Item"), 
  ) %>% 
  mutate(name = fct_relevel(name, "σ Participant:\nIntercept", 
    "σ Participant:\nPalatal", "Cor. Participant:\nInt., Palatal", 
    "σ Item:\nIntercept"))

dur_data_summary <- group_by(dur_tab_dat, name, type) %>% 
  mean_qi(value, .width = 0.95) %>% 
  mutate_if(is.numeric, specify_decimal, k = 2)

dur_forest <- dur_tab_dat %>% 
  ggplot(., aes(x = value, y = name)) + 
    facet_grid(type ~ ., scales = "free", space = "free", switch = "y") + 
    geom_vline(xintercept = 0, lty = 3) + 
    stat_halfeye(aes(fill = type), slab_type = "histogram", breaks = 30, 
      outline_bars = T, slab_color = "white", slab_size = 0.3, 
      point_fill = "white", pch = 21, show.legend = F) +
    scale_fill_manual(values = alpha(my_colors[c(1, 3)], 0.8)) + 
    geom_text(data = dur_data_summary, hjust = "inward", family = "Times", 
      aes(group = type, label = glue::glue("{value} [{.lower}, {.upper}]   "), 
        x = Inf), size = 3.25) +
    coord_cartesian(xlim = c(-0.75, 1.8)) + 
    scale_x_continuous(breaks = c(-0.5, 0, 0.5, 1)) + 
    scale_y_discrete(limits = rev, position = "right") + 
    labs(y = NULL, x = "Estimate") + 
    my_theme(base_family = "Times", base_size = 13) + 
    theme(strip.placement = "outside", strip.text.y = element_text(hjust = 1), 
      axis.text.y = element_text(hjust = 0), axis.ticks.y = element_blank(),
      plot.background = element_rect(colour = "black", size = 0.5))

ggsave(
  filename = "duration_forest.png", 
  plot = dur_forest, 
  path = here("figs", "manuscript"), width = 6.5, height = 3.75, dpi = 600
  )

# -----------------------------------------------------------------------------







# GAMMs: Time course of [j]: --------------------------------------------------

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

#
# F1
#

b_gam_f1 <- brm(
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
  data = carrier_tc_final_gamm, 
  file = here("models", "b_gam_f1")
  ) 

#
# Intensity
#

b_gam_int <- brm(
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
  data = carrier_tc_final_gamm, 
  file = here("models", "b_gam_int")
  ) 




grid <- carrier_tc_final_gamm %>%
  data_grid(is_palatal, time_course_segment = seq(1, 100, length.out = 20), participant)

p_f1_tc <- grid %>% 
  add_epred_draws(b_gam_f1, ndraws = 200, re_formula = NULL) %>% 
  mutate(is_palatal = str_to_title(is_palatal)) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = .epred)) + 
    stat_summary(aes(group = interaction(.draw, is_palatal), color = is_palatal), 
      fun = mean, geom = "line", size = 0.5, alpha = 0.1) + 
    geom_hline(yintercept = 0, lty = 3) + 
    stat_summary(aes(group = is_palatal), fun = mean, geom = "line", 
      size = 3, color = "white") + 
    stat_summary(aes(color = is_palatal), fun = mean, geom = "line", 
      size = 1, alpha = 0.7) + 
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    coord_cartesian(ylim = c(-1, 1)) + 
    labs(y = "Normalized F1", x = "") + 
    annotate("text", label = "(A)", x = 0.05, y = 0.95, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(legend.position = c(0.15, 0.1), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA))

p_f1_tc_diff <- grid %>%
  add_epred_draws(b_gam_f1, re_formula = NA, ndraws = 200) %>% 
  ungroup() %>% 
  select(participant, is_palatal, time_course_segment, .epred) %>% 
  group_by(participant, is_palatal) %>% 
  mutate(row = row_number()) %>% 
  pivot_wider(names_from = "is_palatal", values_from = ".epred") %>% 
  mutate(diff =  palatal - other) %>% 
  group_by(time_course_segment) %>% 
  mutate(dist = seq_along(time_course_segment)) %>% 
  ungroup() %>% 
  mutate(get_color = "F1 diff.\nPalatal − Other") %>% 
  ggplot(., aes(x = time_course_segment / 100, y = diff)) + 
    geom_line(aes(group = dist), color = alpha(my_colors[2], 0.01), size = 0.5) + 
    geom_hline(yintercept = 0, lty = 3) + 
    stat_summary(fun = mean, geom = "line", size = 3, color = "white") + 
    stat_summary(aes(color = get_color), fun = mean, geom = "line", size = 1, 
      alpha = 0.7) + 
    scale_color_manual(name = NULL, values = my_colors[2]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    scale_y_continuous(position = "right") + 
    coord_cartesian(ylim = c(-1, 1)) + 
    labs(y = NULL, x = "Time course") + 
    annotate("text", label = "(B)", x = 0.05, y = 0.95, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(
      legend.position = c(0.25, 0.1), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA))

carrier_gam_f1 <- p_f1_tc + p_f1_tc_diff

ggsave(
  filename = "carrier_gam_f1.png", 
  plot = carrier_gam_f1, 
  path = here("figs", "manuscript"), width = 7, height = 3.5, dpi = 600
  )












p_int_tc <- plot(conditional_effects(b_gam_int, 
  spaghetti = T, nsamples = 500), plot = F)[[3]] + 
  scale_color_viridis_d(name = NULL, option = "B", end = 0.8, alpha = 0.1) + 
  scale_x_continuous(labels = c("0%", "25%", "50%", "75%", "100%"), 
    expand = expansion(mult = c(0, 0)), limits = c(-2, 102)) + 
  labs(y = "Intensity (dB)", x = "") + 
  ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 12) + 
  theme(legend.position = c(0.1, 0.9))

p_int_tc_diff <- grid %>%
  add_epred_draws(b_gam_int, re_formula = NA, ndraws = 300) %>% 
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
