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

# Get posterior and calculate probabilites
b_multi_0_post <- as_draws_df(b_multi_0) %>% 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept) %>% 
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

# Plot posteriors
b_multi_0_post %>% 
  ggplot(., aes(x = phi, color = realization, fill = realization)) + 
    stat_slab(alpha = 0.7, color = "white") +
    stat_pointinterval(pch = 21, point_fill = "white", point_size = 4, 
      position = position_dodge(width = .4, preserve = "single"), 
      show.legend = F) +
    scale_fill_manual(name = NULL, values = my_colors) + 
    scale_color_manual(name = NULL, values = my_colors) + 
    coord_cartesian(ylim = c(-0.15, NA)) + 
    labs(y = NULL, x = "P(realization)") + 
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(legend.position = c(0.1, 0.85), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA), 
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank())






# Fit multinomial model with glide predictor and REs
b_multi_1 <- brm(
  response ~ glide + 
    (1 + glide | participant) + 
    (1 | item) + 
    (1 | pre_c), 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong), 
    prior(normal(0, 20), class = b, dpar = muSimplification), 
    prior(normal(0, 20), class = b, dpar = muTriphthong), 
    prior(lkj(2), class = cor, group = participant)
    ),
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(syllabified_trip, !(item %in% labial_remove)), 
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_1"))

# Conditional effects of p(realization | glide)
plot(conditional_effects(b_multi_1, categorical = T, robust = F))[[1]] + 
  scale_fill_manual(name = NULL, values = my_colors) + 
  scale_color_manual(name = NULL, values = my_colors) + 
  labs(x = NULL, y = "P(realization | glide)") + 
    ds4ling::ds4ling_bw_theme(base_size = 13, base_family = "Times") + 
    theme(
     legend.position = c(0.1, 0.85), 
      legend.background = element_blank(), 
      legend.key = element_rect(fill = NA), 
      strip.background = element_rect(fill = NA)) + 
    NULL
