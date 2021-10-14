# What are my questions?
# which response strategy is most common? 
# How does this vary as a function of glide type and preceding consonant?
# How can I answer them?
# Plots, frequencies, multinomial regression
labial_remove <- c("lakabuaisto", "lakafuaisto", "lakapuaisto")

test_mod_0 <- brm(
  response ~ 1 + 
    (1 | participant) + 
    (1 | item), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(syllabified_trip, !(item %in% labial_remove)), 
  family = categorical())

f <- fitted(test_mod_0)
f[1, , ] %>% 
  t() %>% 
  round(digits = 2) %>% 
  data.frame() %>% 
  rownames_to_column("level") %>% 
  ggplot(aes(x = level, y = Estimate)) +
  geom_pointrange(aes(ymin = Q2.5, ymax = Q97.5), size = 1, fatten = 2) +
  scale_y_continuous(NULL, labels = scales::percent,
    expand = expansion(mult = c(0.05, 0.05)), limits = c(0, NA))


test_mod <- brm(
  response ~ glide + 
    (1 + glide | id | participant) + 
    (1 | item), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(syllabified_trip, !(item %in% labial_remove)), 
  family = categorical())

syllabified_trip %>%
  data_grid(glide, item, participant) %>% 
  filter(!(item %in% labial_remove)) %>% 
  add_epred_draws(test_mod, re_formula = NA, ndraws = 100) %>% 
  ggplot(aes(y = .epred, x = .category, color = .category, shape = .category)) + 
  stat_pointinterval(.width = c(0.66, 0.95), point_fill = "white", 
    show.legend = F) +
  scale_color_viridis_d(option = "B", end = 0.8) + 
  scale_shape_manual(values = c(21, 22, 23)) + 
  facet_grid(. ~ glide) +
  labs(title = "P(realization | glide)", xlab = "age group") + 
  ds4ling::ds4ling_bw_theme()
