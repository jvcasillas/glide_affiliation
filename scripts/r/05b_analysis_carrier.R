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

# model formula
dur_mod_formula <- 
  brmsformula(dur_std ~ palatal_sum +
       (1 + palatal_sum | participant) + 
       (1 | item))

# Main duration mod (i)
b_dur_mod <- brm(
  formula = dur_mod_formula, 
  chains = 4, iter = 2000, warmup = 1000, cores = 4, 
  data = carrier_dur_final, 
  control = list(adapt_delta = 0.99), 
  backend = "cmdstanr", 
  prior = c(
    prior(normal(0, 0.2), class = Intercept), 
    prior(normal(0, 0.5), class = b), 
    prior(cauchy(0, 1), class = sd), 
    prior(lkj(10), class = cor)
  ), 
  file = here("models", "b_dur_mod")
)

# Prep [u] data
carrier_dur_u <- carrier_u %>% 
  group_by(., participant, item, is_palatal) %>% 
  summarize(., dur = mean(duration), .groups = "drop") %>% 
  mutate(dur_std = (dur - mean(dur)) / sd(dur), 
         palatal_sum = if_else(is_palatal == "palatal", 1, -1)) 

# Fit [u] comparison model
b_dur_u_mod <- brm(
  formula = dur_mod_formula, 
  chains = 4, iter = 2000, warmup = 1000, cores = 4, 
  data = carrier_dur_u, 
  control = list(adapt_delta = 0.99), 
  backend = "cmdstanr", 
  prior = c(
    prior(normal(0, 0.2), class = Intercept), 
    prior(normal(0, 0.5), class = b), 
    prior(cauchy(0, 1), class = sd), 
    prior(lkj(10), class = cor)
  ), 
  file = here("models", "b_dur_u_mod")
)


# Get posterior draws for main model
post_dur <- as_draws_df(b_dur_mod) %>% 
  select(starts_with("b_")) %>% 
  transmute(
    palatal = b_Intercept + b_palatal_sum, 
    other = b_Intercept - b_palatal_sum, 
    diff = palatal - other
  ) 

# Get posterior draws for u comparison model
post_dur_u <- as_draws_df(b_dur_u_mod) %>% 
  select(starts_with("b_")) %>% 
  transmute(
    palatal = b_Intercept + b_palatal_sum, 
    other = b_Intercept - b_palatal_sum, 
    diff = palatal - other
  ) 

#
# Plot and compare
#

p_dur_param <- post_dur %>% 
  select(-diff) %>% 
  pivot_longer(cols = everything(), names_to = "param", values_to = "estimate") %>% 
  mutate(param = str_to_title(param)) %>% 
  ggplot(., aes(x = estimate, fill = param, color = param)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(aes(y = 0), pch = 21, point_fill = "white", point_size = 3, 
      position = position_dodge(width = .3, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = "[j]", values = my_colors[c(1, 3)]) + 
    scale_color_manual(name = "[j]", values = my_colors[c(1, 3)]) + 
    labs(y = NULL, x = NULL) + 
    annotate("text", label = "(A)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(legend.position = c(0.15, 0.55), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text = element_blank(),
      axis.ticks = element_blank())

p_dur_diff <- post_dur %>% 
  ggplot(., aes(x = diff)) + 
    stat_slab(alpha = 0.7, color = "white", fill = my_colors[2]) +
    stat_pointinterval(aes(y = 0), pch = 21, point_fill = "white", point_size = 3, 
      position = position_dodge(width = .3, preserve = "single"), 
      color = my_colors[2], show.legend = F) + 
    geom_vline(xintercept = 0, lty = 3) + 
    labs(y = NULL, x = NULL) + 
    annotate("text", label = "(B)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(axis.text = element_blank(), axis.ticks = element_blank())

duration_i <- p_dur_param + p_dur_diff

p_dur_u_param <- post_dur_u %>% 
  select(-diff) %>% 
  pivot_longer(cols = everything(), names_to = "param", values_to = "estimate") %>% 
  mutate(param = str_to_title(param)) %>% 
  ggplot(., aes(x = estimate, fill = param, color = param)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(aes(y = 0), pch = 21, point_fill = "white", point_size = 3, 
      position = position_dodge(width = .3, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = "[w]", values = my_colors[c(1, 3)]) + 
    scale_color_manual(name = "[w]", values = my_colors[c(1, 3)]) + 
    labs(y = NULL, x = "Duration (std.)") + 
    annotate("text", label = "(C)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(legend.position = c(0.15, 0.55), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_dur_u_diff <- post_dur_u %>% 
  ggplot(., aes(x = diff)) + 
    stat_slab(alpha = 0.7, color = "white", fill = my_colors[2]) +
    stat_pointinterval(aes(y = 0), pch = 21, point_fill = "white", point_size = 3, 
      position = position_dodge(width = .3, preserve = "single"), 
      color = my_colors[2], show.legend = F) + 
    geom_vline(xintercept = 0, lty = 3) + 
    labs(y = NULL, x = "Duration difference") + 
    annotate("text", label = "(D)", x = -2, y = 0.95, family = "Times") + 
    coord_cartesian(ylim = c(-0.1, NA), xlim = c(-2.2, 2.2)) + 
    ds4ling::ds4ling_bw_theme(base_size = 12, base_family = "Times") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

duration_u <- p_dur_u_param + p_dur_u_diff

duration_all <- duration_i / duration_u

ggsave(
  filename = "duration_all.png", 
  plot = duration_all, 
  path = here("figs", "manuscript"), 
  scale = 1, width = 7, height = 5.75, dpi = 600
  )




#
# Duration mod forest plot
#

# Get posterior and cleanup colnames and term names
dur_tab_dat <- as_draws_df(b_dur_mod) %>% 
  select(starts_with(c("b_", "sd_", "cor_p", "sigma"))) %>% 
  pivot_longer(cols = everything()) %>% 
  mutate(type = case_when(
    startsWith(name, "b_") ~ "Population", 
    startsWith(name, "sd_") ~ "Grouping", 
    startsWith(name, "cor") ~ "Grouping", 
    TRUE ~ "Family"), 
    type = fct_relevel(type, "Population", "Grouping")) %>% 
  mutate(
    name = case_when(
      name == "b_Intercept" ~ "Intercept", 
      name == "b_palatal_sum" ~ "Palatal", 
      name == "sd_item__Intercept" ~ "σ Item:\nIntercept", 
      name == "sd_participant__Intercept" ~ "σ Participant:\nIntercept", 
      name == "sd_participant__palatal_sum" ~ "σ Participant:\nPalatal", 
      name == "cor_participant__Intercept__palatal_sum" ~ "r Participant:\nInt., Palatal", 
      name == "sigma" ~ "σ"
    )
  ) %>% 
  mutate(name = fct_relevel(name, "σ Participant:\nIntercept", 
    "σ Participant:\nPalatal", "r Participant:\nInt., Palatal", 
    "σ Item:\nIntercept"))

# Summarize posterior for printing estimates in plot
dur_data_summary <- group_by(dur_tab_dat, name, type) %>% 
  mean_qi(value, .width = 0.95) %>% 
  mutate_if(is.numeric, specify_decimal, k = 2)

# Forest plot
dur_forest <- dur_tab_dat %>% 
  #filter(name != "r Participant:\nInt., Palatal") %>% 
  ggplot(., aes(x = value, y = name)) + 
    facet_grid(type ~ ., scales = "free", space = "free") + 
    geom_vline(xintercept = 0, lty = 3) + 
    stat_halfeye(aes(fill = type), slab_type = "histogram", breaks = 30, 
      outline_bars = T, slab_color = "white", slab_size = 0.3, 
      point_fill = "white", pch = 21, show.legend = F) +
    scale_fill_manual(values = alpha(my_colors[1:3], 0.8)) + 
    geom_text(data = filter(dur_data_summary, name != "r: Int., Palatal"), 
      hjust = 1, family = "Times", size = 3.25, 
      aes(group = type, label = glue::glue("{value} [{.lower}, {.upper}]"),
        x = -0.7)) +
    coord_cartesian(xlim = c(-1.15, 1.35)) + 
    scale_x_continuous(breaks = c(-0.5, 0, 0.5, 1)) + 
    scale_y_discrete(limits = rev, position = "left") + 
    labs(y = NULL, x = "Estimate") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(plot.margin = unit(x = c(0, 0, 0, 0), units = "mm"), 
      strip.placement = "outside", strip.background = element_blank(), 
      axis.text.y = element_text(hjust = 1), axis.ticks.y = element_blank())

ggsave(
  filename = "duration_forest.png", 
  plot = dur_forest, 
  path = here("figs", "manuscript"), width = 6.5, height = 5.5, dpi = 600
  )

#
# Duration mod table
#

bayestestR::describe_posterior(
  posteriors = b_dur_mod, 
  test = "p_direction", 
  effects = "fixed") %>%
  as_tibble() %>% 
  mutate_if(is.numeric, specify_decimal, k = 2) %>% 
  mutate(
    Parameter = str_remove_all(Parameter, "b_"), 
    Parameter = str_replace_all(Parameter, "palatal_sum", "Palatal"), 
    Estimate = glue("{Median} [{CI_low}, {CI_high}]"), 
    Prior = if_else(Parameter == "Intercept", "Normal(0, 0.2)", "Normal(0, 0.5)")) %>% 
  select(Parameter, Estimate, `P(direction)` = pd, Rhat, ESS, Prior) %>% 
  saveRDS(., file = here("tables", "tab_dur.rds"))

# -----------------------------------------------------------------------------




















# GAMMs: Time course of [j]: --------------------------------------------------

# set participant to factor
# set is_palatal to ordered variable and relevel so palatal is reference
carrier_tc_final_gamm <- carrier_tc_final %>% 
  mutate(
    participant = as.factor(participant), 
    is_palatal_ord = as.ordered(is_palatal), 
    is_palatal_ord = fct_relevel(is_palatal_ord, 'palatal'), 
    int_norm = (`in` - mean(`in`)) / sd(`in`), 
    palatal_sum = if_else(is_palatal == "palatal", 1, -1))

# dummy code is_palatal_ord
contrasts(carrier_tc_final_gamm$is_palatal_ord) <- "contr.treatment" 

# Set priors
priors <- c(
    prior(normal(0, 0.5), class = Intercept), 
    prior(normal(0, 0.5), class = b), 
    prior(student_t(3, 0, 1), class = sds, coef = s(time_course_segment, bs = "cr", k = 3)), 
    prior(student_t(3, 0, 2.5), class = sds, coef = s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 4)), 
    prior(student_t(3, 0, 2.5), class = sds, coef = s(time_course_segment, participant, bs = "fs", m = 1, k = 3)), 
    prior(cauchy(0, 2), class = sigma)
  )

# F1 GAM
b_gam_f1 <- brm(
  formula = f1norm ~ is_palatal_ord + 
    s(time_course_segment, bs = "cr", k = 3) +                    # reference smooth
    s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 4) +   # difference smooth
    s(time_course_segment, participant, bs = "fs", m = 1, k = 3), # random 
  family = gaussian(), 
  prior = priors, 
  backend = "cmdstanr", iter = 2000, warmup = 1000, cores = 4,
  control = list(adapt_delta = 0.999999, max_treedepth = 20), 
  data = carrier_tc_final_gamm, 
  file = here("models", "b_gam_f1")
  ) 

# Intensity GAM
b_gam_int <- brm(
  formula = int_norm ~ is_palatal_ord + 
    s(time_course_segment, bs = "cr", k = 3) +                    # reference s
    s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 4) +   # diff s
    s(time_course_segment, participant, bs = "fs", m = 1, k = 3), # random s
  family = gaussian(), 
  prior = priors, 
  backend = "cmdstanr", iter = 2000, warmup = 1000, cores = 4,
  control = list(adapt_delta = 0.999999, max_treedepth = 20), 
  data = carrier_tc_final_gamm, 
  file = here("models", "b_gam_int")
  ) 

# Create grid for posterior samples and plotting
grid <- carrier_tc_final_gamm %>%
  data_grid(is_palatal_ord, time_course_segment = seq(1, 100, length.out = 20), 
    participant)

p_f1_tc <- grid %>% 
  add_epred_draws(b_gam_f1, ndraws = 200, re_formula = NULL) %>% 
  mutate(is_palatal = str_to_title(is_palatal_ord)) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = .epred)) + 
    stat_summary(aes(group = interaction(.draw, is_palatal), color = is_palatal), 
      fun = mean, geom = "line", size = 0.5, alpha = 0.1) + 
    geom_hline(yintercept = 0, lty = 3) + 
    stat_summary(aes(group = is_palatal), fun = mean, geom = "line", 
      size = 2.5, color = "white") + 
    stat_summary(aes(color = is_palatal), fun = mean, geom = "line", size = 1) +
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    scale_y_reverse() + 
    coord_cartesian(ylim = c(1, -1)) + 
    labs(y = "Normalized F1", x = "") + 
    annotate("text", label = "(A)", x = 0.05, y = -0.95, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(legend.position = c(0.15, 0.12), legend.background = element_blank(),
      legend.key = element_rect(fill = NA), axis.text = element_text(size = 9.5))

p_f1_tc_diff <- grid %>%
  add_epred_draws(b_gam_f1, re_formula = NA, ndraws = 200) %>% 
  ungroup() %>% 
  select(participant, is_palatal = is_palatal_ord, time_course_segment, .epred) %>% 
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
    stat_summary(fun = mean, geom = "line", size = 2.5, color = "white") + 
    stat_summary(aes(color = get_color), fun = mean, geom = "line", size = 1) + 
    scale_color_manual(name = NULL, values = my_colors[2]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    scale_y_reverse(position = "right") + 
    coord_cartesian(ylim = c(1, -1)) + 
    labs(y = NULL, x = "Time course") + 
    annotate("text", label = "(B)", x = 0.05, y = -0.95, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(legend.position = c(0.25, 0.12), legend.background = element_blank(),
      legend.key = element_rect(fill = NA), axis.text = element_text(size = 9.5))

carrier_gam_f1 <- p_f1_tc + p_f1_tc_diff

ggsave(
  filename = "carrier_gam_f1.png", 
  plot = carrier_gam_f1, 
  path = here("figs", "manuscript"), width = 7, height = 3, dpi = 600
  )

# Plot intensity model
p_int_tc <- grid %>% 
  add_epred_draws(b_gam_int, ndraws = 200, re_formula = NULL) %>% 
  mutate(is_palatal = str_to_title(is_palatal_ord)) %>% 
  ggplot(., aes(x = time_course_segment / 100, y = .epred)) + 
    stat_summary(aes(group = interaction(.draw, is_palatal), color = is_palatal), 
      fun = mean, geom = "line", size = 0.5, alpha = 0.1) + 
    geom_hline(yintercept = 0, lty = 3) + 
    stat_summary(aes(group = is_palatal), fun = mean, geom = "line", 
      size = 2.5, color = "white") + 
    stat_summary(aes(color = is_palatal), fun = mean, geom = "line", size = 1) +
    scale_color_manual(name = NULL, values = my_colors[c(1, 3)]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    coord_cartesian(ylim = c(-1.5, 1.5)) + 
    labs(y = "Normalized Intenisity", x = "") + 
    annotate("text", label = "(A)", x = 0.05, y = 1.45, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(legend.position = c(0.15, 0.12), legend.background = element_blank(),
      legend.key = element_rect(fill = NA), axis.text = element_text(size = 9.5))

p_int_tc_diff <- grid %>%
  add_epred_draws(b_gam_int, re_formula = NA, ndraws = 200) %>% 
  ungroup() %>% 
  select(participant, is_palatal = is_palatal_ord, time_course_segment, .epred) %>% 
  group_by(participant, is_palatal) %>% 
  mutate(row = row_number()) %>% 
  pivot_wider(names_from = "is_palatal", values_from = ".epred") %>% 
  mutate(diff =  palatal - other) %>% 
  group_by(time_course_segment) %>% 
  mutate(dist = seq_along(time_course_segment)) %>% 
  ungroup() %>% 
  mutate(get_color = "Intensity diff.\nPalatal − Other") %>% 
  ggplot(., aes(x = time_course_segment / 100, y = diff)) + 
    geom_line(aes(group = dist), color = alpha(my_colors[2], 0.01), size = 0.5) + 
    geom_hline(yintercept = 0, lty = 3) + 
    stat_summary(fun = mean, geom = "line", size = 2.5, color = "white") + 
    stat_summary(aes(color = get_color), fun = mean, geom = "line", size = 1) + 
    scale_color_manual(name = NULL, values = my_colors[2]) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.02, 1.02)) + 
    scale_y_continuous(position = "right") + 
    coord_cartesian(ylim = c(-1.5, 1.5)) + 
    labs(y = NULL, x = "Time course") + 
    annotate("text", label = "(B)", x = 0.05, y = 1.45, family = "Times") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(legend.position = c(0.25, 0.12), legend.background = element_blank(),
      legend.key = element_rect(fill = NA), axis.text = element_text(size = 9.5))

carrier_gam_int <- p_int_tc + p_int_tc_diff

ggsave(
  filename = "carrier_gam_int.png", 
  plot = carrier_gam_int, 
  path = here("figs", "manuscript"), width = 7, height = 3, dpi = 600
  )

# Table plots
gam_forest_data <- bind_rows(
  as_draws_df(b_gam_f1) %>% 
    select(starts_with(c("b_", "bs_", "sds_")), sigma) %>% 
    pivot_longer(cols = everything()) %>% 
    mutate(model = "F1"),
  as_draws_df(b_gam_int) %>% 
    select(starts_with(c("b_", "bs_", "sds_")), sigma) %>% 
    pivot_longer(cols = everything()) %>% 
    mutate(model = "Intensity")
  ) %>% 
  separate(col = name, into = c("term", "name"), sep = "_", 
    extra = "merge", fill = "left") %>% 
  mutate(
    term = case_when(
      term == "b" ~ "Parametric\npop. β", 
      term == "bs"~ "Non-parametric\npop. β", 
      term == "sds" ~ "Smooth term\nσ", 
      is.na(term) ~ "Family"), 
    term = fct_relevel(term, "Parametric\npop. β", "Non-parametric\npop. β", 
      "Smooth term\nσ"), 
    name = case_when(
      name == "Intercept" ~ "Intercept", 
      name == "is_palatal_ordother" ~ "Not palatal", 
      name == "stime_course_segment_1" ~ "TC", 
      name == "stime_course_segment:is_palatal_ordother_1" ~ "TC - Not palatal", 
      name == "stime_course_segment_1" ~ "TC", 
      name == "stime_course_segmentis_palatal_ordother_1" ~ "TC - Not palatal", 
      name == "stime_course_segmentparticipant_1" ~ "TC Part. - Not palatal", 
      name == "stime_course_segmentparticipant_2" ~ "TC Part. - Palatal", 
      name == "sigma" ~ "σ"
    ))

gam_data_summary <- gam_forest_data %>% 
  group_by(model, term, name) %>% 
  mean_qi(value, .width = 0.95) %>% 
  mutate_if(is.numeric, specify_decimal, k = 2)

carrier_gam_forest <- gam_forest_data %>% 
  ggplot(., aes(x = value, y = name, fill = model, shape = model)) + 
    facet_grid(term ~ ., scales = "free", space = "free") + 
    geom_vline(xintercept = 0, lty = 3) + 
    stat_pointinterval(position = position_dodge(0.75)) + 
    scale_shape_manual(name = NULL, values = c(21, 23)) + 
    scale_fill_manual(name = NULL, values = my_colors[1:2]) + 
    geom_text(data = gam_data_summary, 
      hjust = 1, family = "Times", size = 3, position = position_dodge(0.75), 
      aes(group = interaction(term, model), label = glue::glue("{value} [{.lower}, {.upper}]"),
        x = -0.6)) +
    coord_cartesian(xlim = c(-1.2, NA)) + 
    scale_x_continuous(breaks = c(-1, 0, 1)) + 
    scale_y_discrete(limits = rev, position = "left") + 
    labs(title = NULL, subtitle = NULL, y = NULL, x = "Estimate") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(
      plot.margin = unit(x = c(0, 0, 0, 0), units = "mm"), 
      legend.margin = margin(t = -0.5, b = 0, unit='cm'), 
      legend.position = "bottom", legend.direction = "horizontal", 
      legend.background = element_blank(), legend.key = element_rect(fill = NA), 
      strip.placement = "outside", strip.background = element_blank(), 
      axis.ticks.y = element_blank(), axis.text.y = element_text(hjust = 1)) +
    guides(fill = guide_legend(override.aes = list(size = 5)))

ggsave(
  filename = "carrier_gam_forest.png", 
  plot = carrier_gam_forest, 
  path = here("figs", "manuscript"), width = 7.5, height = 5.5, dpi = 600
  )

# Just F1 forest
carrier_gam_forest_f1 <- gam_forest_data %>% 
  filter(model == "F1") %>% 
  ggplot(., aes(x = value, y = name, fill = term)) + 
    facet_grid(term ~ ., scales = "free", space = "free") + 
    geom_vline(xintercept = 0, lty = 3) + 
    stat_halfeye(fill = "darkgrey", slab_type = "histogram", breaks = 30, 
      outline_bars = T, slab_color = "white", slab_size = 0.3, 
      point_fill = "white", pch = 21, show.legend = F) +
    geom_text(data = gam_data_summary %>% filter(model == "F1"), 
      hjust = 1, family = "Times", size = 3, 
      aes(group = interaction(term, model), label = glue::glue("{value} [{.lower}, {.upper}]"),
        x = -0.6)) +
    coord_cartesian(xlim = c(-1.25, 3)) + 
    scale_y_discrete(limits = rev, position = "left") + 
    labs(title = NULL, subtitle = NULL, y = NULL, x = "Estimate") + 
    ds4ling::ds4ling_bw_theme(base_family = "Times", base_size = 13) + 
    theme(
      plot.margin = unit(x = c(0, 0, 0, 0), units = "mm"), 
      strip.placement = "outside", strip.background = element_blank(), 
      axis.ticks.y = element_blank(), axis.text.y = element_text(hjust = 1))

ggsave(
  filename = "carrier_gam_forest_f1.png", 
  plot = carrier_gam_forest_f1, 
  path = here("figs", "manuscript"), width = 7.5, height = 5.5, dpi = 600
  )



#
# Tables
#

bayestestR::describe_posterior(
  posteriors = b_gam_f1, 
  test = "p_direction", 
  effects = "fixed") %>%
  as_tibble() %>% 
  mutate_if(is.numeric, specify_decimal, k = 2) %>% 
  mutate(
    Parameter = case_when(
      Parameter == "b_Intercept" ~ "Intercept", 
      Parameter == "b_is_palatal_ordother" ~ "Not palatal", 
      Parameter == "bs_stime_course_segment_1" ~ "Time course", 
      Parameter == "bs_stime_course_segment:is_palatal_ordother_1" ~ "Time course: Not palatal"
    ), 
    Estimate = glue("{Median} [{CI_low}, {CI_high}]"), 
    Prior = case_when(
      Parameter == "Intercept" ~ "Normal(0, 0.5)", 
      Parameter == "Not palatal" ~ "Normal(0, 0.5)", 
      TRUE ~ "student_t(3, 0, 1)"), 
    Function = if_else(Parameter %in% c("Intercept", "Not palatal"), " ", "Smooth")
    ) %>% 
  select(Parameter, Function, Estimate, `P(direction)` = pd, Rhat, ESS, Prior) %>% 
  saveRDS(., file = here("tables", "tab_gam_f1.rds"))



# Intensity model
bayestestR::describe_posterior(
  posteriors = b_gam_int, 
  test = "p_direction", 
  effects = "fixed") %>%
  as_tibble() %>% 
  mutate_if(is.numeric, specify_decimal, k = 2) %>% 
  mutate(
    Parameter = case_when(
      Parameter == "b_Intercept" ~ "Intercept", 
      Parameter == "b_is_palatal_ordother" ~ "Not palatal", 
      Parameter == "bs_stime_course_segment_1" ~ "Time course", 
      Parameter == "bs_stime_course_segment:is_palatal_ordother_1" ~ "Time course: Not palatal"
    ), 
    Estimate = glue("{Median} [{CI_low}, {CI_high}]"), 
    Prior = case_when(
      Parameter == "Intercept" ~ "Normal(0, 0.5)", 
      Parameter == "Not palatal" ~ "Normal(0, 0.5)", 
      TRUE ~ "student_t(3, 0, 1)"), 
    Function = if_else(Parameter %in% c("Intercept", "Not palatal"), " ", "Smooth")
    ) %>% 
  select(Parameter, Function, Estimate, `P(direction)` = pd, Rhat, ESS, Prior) %>% 
  saveRDS(., file = here("tables", "tab_gam_int.rds"))

# -----------------------------------------------------------------------------
