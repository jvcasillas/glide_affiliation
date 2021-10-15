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



# Create vector of items to remove (cant remember why)
labial_remove <- c("lakabuaisto", "lakafuaisto", "lakapuaisto")

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





# Get posterior samples for each model and calculate phi
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





# Probability table with CrI's
b_multi_0_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, round, digits = 2) %>% 
  mutate(`95% CrI` = glue::glue("[{.lower}, {.upper}]")) %>% 
  select(Realization = realization, Probability = phi, `95% CrI`)  

b_multi_1a_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, round, digits = 2) %>% 
  mutate(`95% CrI` = glue::glue("[{.lower}, {.upper}]")) %>% 
  select(Realization = realization, Probability = phi, `95% CrI`)  

b_multi_1b_post %>% 
  group_by(realization) %>% 
  mean_qi(phi) %>% 
  mutate_if(is.double, round, digits = 2) %>% 
  mutate(`95% CrI` = glue::glue("[{.lower}, {.upper}]")) %>% 
  select(Realization = realization, Probability = phi, `95% CrI`)  




# Plot posteriors
p_multi_0 <- b_multi_0_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .4, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors) + 
    scale_color_manual(name = NULL, values = my_colors) + 
    coord_cartesian(ylim = c(-0.15, NA)) + 
    scale_x_continuous(labels = scales::percent, 
      expand = expansion(mult = c(0, 0)), limits = c(-0.0225, 1.02)) + 
    labs(y = NULL, x = "P(realization)") + 
    annotate(geom = "text", label = "(A)", x = 0, y = 0.95, color = "grey30") +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(legend.position = c(0.8, 0.75), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())

p_multi_i <- b_multi_1a_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white", show.legend = F) +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .4, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors) + 
    scale_color_manual(name = NULL, values = my_colors) + 
    coord_cartesian(ylim = c(-0.15, NA)) + 
    scale_x_continuous(labels = scales::percent, limits = c(0, 1)) + 
    labs(y = NULL, x = "P(realization | /i/)") + 
    annotate(geom = "text", label = "(B)", x = 0, y = 0.95, color = "grey30") +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

p_multi_u <- b_multi_1b_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white", show.legend = F) +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .4, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors) + 
    scale_color_manual(name = NULL, values = my_colors) + 
    coord_cartesian(ylim = c(-0.15, NA)) + 
    scale_x_continuous(labels = scales::percent, limits = c(0, 1)) + 
    labs(y = NULL, x = "P(realization | /u/)") + 
    annotate(geom = "text", label = "(C)", x = 0, y = 0.95, color = "grey30") +
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

p_multi_0 / (p_multi_i + p_multi_u)
