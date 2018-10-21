# What are my questions?
# which response strategy is most common? 
# How does this vary as a function of glide type and preceding consonant?
# How can I answer them?
# Plots, frequencies, multinomial regression
labial_remove <- c("lakabuaisto", "lakafuaisto", "lakapuaisto")

test_mod <- brm(response ~ glide + 
               (glide + pre_c | participant) + 
               (glide + pre_c | item), 
                control = list(adapt_delta = 0.99), 
                data = filter(syllabified_trip, !(item %in% labial_remove)), 
                family = categorical())

syllabified_trip %>% 
  data_grid(glide, pre_c, item, participant) %>% 
  add_fitted_draws(test_mod, dpar = TRUE) %>% 
  ggplot(., aes(x = .category, y = .value)) + 
    stat_pointinterval(position = position_dodge(width = .4), 
                       .width = c(.66, .95), show.legend = T) + 
    scale_size_continuous(guide = F)

syllabified_trip %>%
  data_grid(glide, pre_c, item, participant) %>% 
  add_fitted_draws(test_mod) %>% 
  within(levels(.category) <- levels(syllabified_trip$response)) %>%
  ggplot(aes(x = .value, y = .category)) +
  stat_summaryh(fun.x = median, geom = "barh", fill = "gray75", width = 1, 
                color = "white") +
  stat_pointintervalh() +
  coord_cartesian(expand = FALSE) +
  facet_grid(. ~ glide, switch = "x") +
  theme_classic() +
  theme(strip.background = element_blank(), strip.placement = "outside") +
  ggtitle("P(tobacco consumption category | age group)") +
  xlab("age group")




data(esoph)

m_esoph_brm = brm(tobgp ~ agegp, data = esoph, family = cumulative())

esoph %>%
  data_grid(agegp) %>%
  add_fitted_draws(m_esoph_brm, dpar = TRUE) %>%
  ggplot(aes(x = agegp, y = .value, color = .category)) +
  stat_pointinterval(position = position_dodge(width = .4), .width = c(.66, .95), show.legend = TRUE) +
  scale_size_continuous(guide = FALSE)
