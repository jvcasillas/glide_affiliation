# Analyses syllabification task -----------------------------------------------
#
# Questions
# - which response strategy is most common? 
# - How does this vary as a function of glide type and preceding consonant?
#
# How can I answer them?
# Plots, frequencies, multinomial regression
#
# -----------------------------------------------------------------------------




# Set up ----------------------------------------------------------------------

# Source helpers and load data
source(here::here("scripts", "r", "03_load_data.R"))

# Create vector of items to remove 
# (Hypothesis is that palatal C + palatal glide should ilicit)
labial_remove <- c("lakabuaisto", "lakafuaisto", "lakapuaisto")

# -----------------------------------------------------------------------------




# Fit models ------------------------------------------------------------------

# Fit intercept-only multinomial model to get CrI around response rates
b_multi_0 <- brm(
  response ~ 1, 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  data = filter(syllabified_trip, !(item %in% labial_remove)), 
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_0"))

b_multi_1a <- brm(
  response ~ 1, 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(syllabified_trip, !(item %in% labial_remove), 
    glide == "i"), 
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_1a"))

b_multi_1b <- brm(
  response ~ 1, 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(syllabified_trip, !(item %in% labial_remove), 
    glide == "u"), 
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_1b"))

# -----------------------------------------------------------------------------




# Get posterior samples for each model and calculate phi ----------------------
b_multi_0_post <- as_draws_df(b_multi_0) %>% 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept) %>% 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") %>% 
  group_by(iter) %>% 
  mutate(phi = exp(estimate) / sum(exp(estimate)))

b_multi_1a_post <- as_draws_df(b_multi_1a) %>% 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept 
    ) %>% 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") %>% 
  group_by(iter) %>% 
  mutate(phi = exp(estimate) / sum(exp(estimate)))

b_multi_1b_post <- as_draws_df(b_multi_1b) %>% 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept 
    ) %>% 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") %>% 
  group_by(iter) %>% 
  mutate(phi = exp(estimate) / sum(exp(estimate)))

# -----------------------------------------------------------------------------




# Probability tables with CrI's -----------------------------------------------

glide_cri <- b_multi_0_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, specify_decimal, k = 2) %>% 
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")) %>%
  select(realization, cri)  

glide_i_cri <- b_multi_1a_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, specify_decimal, k = 2) %>% 
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")) %>%
  select(realization, cri)  

glide_u_cri <- b_multi_1b_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, specify_decimal, k = 2) %>% 
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")) %>%
  select(realization, cri)  

# -----------------------------------------------------------------------------




# Plots -----------------------------------------------------------------------

p_multi_0 <- b_multi_0_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(aes(y = -0.025), pch = 21, point_fill = "white", 
      point_size = 4, show.legend = F, 
      position = position_dodge(width = .4, preserve = "single")) +
    scale_fill_manual(name = NULL, values = my_colors, labels = NULL) + 
    scale_color_manual(name = NULL, values = my_colors, labels = NULL) + 
    coord_cartesian(ylim = c(-0.2, NA)) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.0225, 1.02)) + 
    labs(y = NULL, x = NULL) + 
    annotate("text", label = "(A)", x = 0, y = 0.95, family = "Times") + 
    annotate("text", label = "P(response)", x = 0.67, y = 0.9, size = 3.25) +
    annotate("text", x = c(0.65, 0.95), y = 0.65, hjust = c(0, 1), size = 3.25,
      family = "Times", label = glue::glue("
        {glide_cri[1, ]}
        {glide_cri[2, ]}
        {glide_cri[3, ]}")) +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(legend.position = c(0.63, 0.6875), 
      legend.spacing.y = unit(0, 'cm'), 
      legend.key.height = unit(0.5, "cm"),
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_multi_i <- b_multi_1a_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(aes(y = -0.025), pch = 21, point_fill = "white", 
      point_size = 4, position = position_dodge(width = .4, preserve = "single"),
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors, labels = NULL) + 
    scale_color_manual(name = NULL, values = my_colors, labels = NULL) + 
    coord_cartesian(ylim = c(-0.2, NA)) + 
    scale_x_continuous(labels = scales::percent, limits = c(0, 1)) + 
    labs(y = NULL, x = NULL) + 
    annotate("text", label = "(B)", x = 0, y = 0.95, family = "Times") + 
    annotate("text", label = "P(response | [j])", x = 0.78, y = 0.9, size = 3.25) + 
    annotate("text", x = 1, y = 0.665, hjust = 1, size = 3.25, family = "Times", 
      label = glue::glue("
        {glide_i_cri[1, 2]}
        {glide_i_cri[2, 2]}
        {glide_i_cri[3, 2]}")) +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(legend.position = c(0.65, 0.7), 
      legend.spacing.y = unit(0, 'cm'), 
      legend.key.height = unit(0.5, "cm"),
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_multi_u <- b_multi_1b_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(aes(y = -0.025), pch = 21, point_fill = "white", 
      point_size = 4, position = position_dodge(width = .4, preserve = "single"),
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors, labels = NULL) + 
    scale_color_manual(name = NULL, values = my_colors, labels = NULL) + 
    coord_cartesian(ylim = c(-0.2, NA)) + 
    scale_x_continuous(labels = scales::percent, limits = c(0, 1)) + 
    labs(y = NULL, x = NULL) +
    annotate("text", label = "(C)", x = 0, y = 0.95, family = "Times") + 
    annotate("text", label = "P(response | [w])", x = 0.78, y = 0.9, size = 3.25) + 
    annotate("text", x = 1, y = 0.665, hjust = 1, size = 3.25, family = "Times",
      label = glue::glue("
        {glide_u_cri[1, 2]}
        {glide_u_cri[2, 2]}
        {glide_u_cri[3, 2]}")) +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(legend.position = c(0.65, 0.7), 
      legend.spacing.y = unit(0, 'cm'), 
      legend.key.height = unit(0.5, "cm"),
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

syllabification_all <- p_multi_0 / (p_multi_i + p_multi_u)

ggsave(
  filename = "syllabification_all.png", 
  plot = syllabification_all, 
  path = here("figs", "manuscript"), width = 7, height = 5.75, dpi = 600
  )

# -----------------------------------------------------------------------------




# Tables ----------------------------------------------------------------------

bind_rows(
  bayestestR::describe_posterior(posteriors = b_multi_0, test = "p_direction", 
    effects = "all", priors = T) %>%
  as_tibble() %>% 
  mutate(Model = "Main"), 
  bayestestR::describe_posterior(posteriors = b_multi_1a, test = "p_direction", 
    effects = "all", priors = T) %>%
  as_tibble() %>% 
  mutate(Model = "[j]"), 
  bayestestR::describe_posterior(posteriors = b_multi_1b, test = "p_direction", 
    effects = "all", priors = T) %>%
  as_tibble() %>% 
  mutate(Model = "[w]") 
  ) %>% 
  mutate_if(is.numeric, specify_decimal, k = 2) %>% 
  mutate(
    Parameter = str_replace_all(Parameter, "b_mu", "μ "), 
    Parameter = str_replace_all(Parameter, "_", ": "), 
    Prior = glue("{Prior_Distribution}(0, 20)"), 
    Prior = str_to_title(Prior), 
    Estimate = glue("{Median} [{CI_low}, {CI_high}]")) %>% 
  select(Model, Parameter, Estimate, `P(direction)` = pd, Rhat, ESS, Prior) %>% 
  saveRDS(., file = here("tables", "tab_multi_all.rds"))

# -----------------------------------------------------------------------------
