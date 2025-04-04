# Phase 2: analysis -----------------------------------------------------------
#
# Authors: Miriam Rodríguez and Joseph V. Casillas
# Last update: 20240508
# Description: 
#  - This script will load and tidy the phase 2 data
#  - This script contains all of the statistical analyses
#
# -----------------------------------------------------------------------------



# Source helpers and packages -------------------------------------------------

source(here::here("scripts", "r", "00_helpers.R"))

# -----------------------------------------------------------------------------




# Load data -------------------------------------------------------------------

# Make vector of the columns we want
phase2_cols <- c(
  "participant", "id", "item", "response", "op1", "op2", "op3", 
  "mouse.clicked_name", "textbox_followup.text"
)

# Get a list of all csv files
# Load them as individual data frames inside a list
# Select only the columns you want (my_cols)
# Bind all the list elements into a single data frame
phase2_temp <- dir_ls(path = here("data", "phase_2"), regexp = ".csv") |> 
  as.list() |> 
  map(read_csv) |> 
  map(.f = function(x) {x[, names(x) %in% phase2_cols]}) |> 
  do.call(what = "rbind", args = _) 

# -----------------------------------------------------------------------------




# Tidy phase 2 data -----------------------------------------------------------

# Pipe
#  - remove unwanted rows (practice trials, routine clicks)
#  - rename columns
#  - recode participant responses to reflect actual text (i.e., "chia-ba" and 
#    not "text_option_1")
#  - change uppercase responses to lowercase

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

phase_2_structure <- phase2_temp |> 
  filter(!is.na(mouse.clicked_name)) |> 
  rename(
    id = participant, 
    speaker_id = id, 
    common_response = response, 
    response = mouse.clicked_name, 
    response_other = textbox_followup.text
  ) |> 
  mutate(
    response = case_when(
      response == "text_option_1"     ~ op1, 
      response == "text_option_2"     ~ op2, 
      response == "text_option_3"     ~ op3, 
      response == "text_option_other" ~ response_other 
    ), 
    response = str_to_lower(response)
  ) |> 
  select(-response_other)


phase_2 <- phase_2_structure |> 
  filter(item %in% critical_items_triphthongs) |> 
  separate(
    col = item, 
    into = c('fluff1', 'glide', 'fluff2'), 
    remove = F, 
    sep = c(4, 6)
  ) |> 
  select(-c(fluff1, fluff2)) |> 
  separate(
    col = glide, 
    into = c('pre_c', 'glide'), 
    sep = 1, remove = T
  ) |> 
  mutate(
    pre_c_voicing = if_else(pre_c %in% c('b', 'd', 'g'), 'voiced', 'voiceless'), 
    pre_c_poa = case_when(
      pre_c %in% c('b', 'p') ~ 'bilabial', 
      pre_c %in% c('d', 't') ~ 'dental',
      pre_c == 'f' ~ 'labiodental', 
      TRUE ~ 'velar'
    ), 
    resp_label = case_when(
      response == op1 ~ "Triphthong", 
      response == op2 ~ "Hiatus", 
      response == op3 ~ "Simplification", 
      TRUE ~ "Simplification"
    )
  ) |> 
  select(
    id:pre_c,
    pre_c_voicing:pre_c_poa, 
    glide, 
    common_response, 
    response, 
    resp_label
  )


phase_2 |> 
  count(resp_label) |> 
  mutate(total = sum(n), prop = n / total)

phase_2 |> 
  group_by(glide) |> 
  count(resp_label) |> 
  mutate(total = sum(n), prop = n / total)

# -----------------------------------------------------------------------------




# Analyses --------------------------------------------------------------------

# Miriam: 
# You can start here. The dataframe you will work with is 'phase_2'
# Don't worry about making any plots for now. Just do the analyses and we 
# will go from there (the plots and other things will be slightly different 
# so we can talk about that later). 
# When you save models you have to make sure you give them new names so you 
# save over the old ones. Ex: 
#
# Old example/name
# file = here("models", "b_multi_0"))
#
# New example/name
# file = here("models", "b_multi_0_phase2"))
#
# I'm sure I am forgetting something, so just give it a go and let me know 
# if/when you have any issues. 
#

# Fit intercept-only multinomial model to get CrI around response rates
b_multi_0 <- brm(
  resp_label ~ 1 + (1 | id) + (1 | speaker_id), 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  data = filter(phase_2), 
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_0_phase2")
)

b_multi_1a <- brm(
  resp_label ~ 1 + (1 | id) + (1 | speaker_id), 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(phase_2, glide == "i"),
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_1a_phase2")
)

b_multi_1b <- brm(
  resp_label ~ 1 + (1 | id) + (1 | speaker_id), 
  prior = c(
    prior(normal(0, 20), class = Intercept, dpar = muSimplification), 
    prior(normal(0, 20), class = Intercept, dpar = muTriphthong)
  ), 
  iter = 2000, warmup = 1000, cores = 4, backend = "cmdstanr", 
  control = list(adapt_delta = 0.99), 
  data = filter(phase_2, glide == "u"),
  family = categorical(link = "logit"), 
  file = here("models", "b_multi_1b_phase2")
)

# -----------------------------------------------------------------------------




# Get posterior samples for each model and calculate phi ----------------------
b_multi_0_post <- as_draws_df(b_multi_0) |> 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept) |> 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") |> 
  group_by(iter) |> 
  mutate(phi = exp(estimate) / sum(exp(estimate)))

b_multi_1a_post <- as_draws_df(b_multi_1a) |> 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept 
  ) |> 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") |> 
  group_by(iter) |>
  mutate(phi = exp(estimate) / sum(exp(estimate)))

b_multi_1b_post <- as_draws_df(b_multi_1b) |> 
  transmute(iter           = 1:n(),
            Hiatus         = 0,  # recall this is the default
            Simplification = b_muSimplification_Intercept, 
            Triphthong     = b_muTriphthong_Intercept 
  ) |> 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") |> 
  group_by(iter) |>
  mutate(phi = exp(estimate) / sum(exp(estimate)))



as_tibble(b_multi_0) |> 
  select(starts_with("r_speaker_id")) |> 
  mutate(iter = 1:n(), Hiatus = 0) |> 
  pivot_longer(cols = -iter, names_to = "realization", values_to = "estimate") |> 
  separate(col = realization, into = c("realization", "speaker"), sep = "\\[") |> 
  mutate(
    realization = str_remove(realization, "r_speaker_id__mu"), 
    speaker = str_remove(speaker, ",Intercept]")
  ) |> 
  group_by(iter, speaker) |>
  mutate(phi = exp(estimate) / sum(exp(estimate))) 


# -----------------------------------------------------------------------------




# Probability tables with CrI's -----------------------------------------------

glide_cri <- b_multi_0_post |> 
  group_by(realization) |>
  mean_qi(phi) |> 
  mutate_if(is.double, specify_decimal, k = 2) |> 
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")
  ) |>
  select(realization, cri)  

glide_i_cri <- b_multi_1a_post |> 
  group_by(realization) |>
  mean_qi(phi) |>
  mutate_if(is.double, specify_decimal, k = 2) |>
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")
  ) |>
  select(realization, cri)

glide_u_cri <- b_multi_1b_post |> 
  group_by(realization) |>
  mean_qi(phi) |>
  mutate_if(is.double, specify_decimal, k = 2) |> 
  mutate(
    realization = glue::glue("{realization}: "), 
    cri =  glue::glue("{phi} [{.lower}, {.upper}]")
  ) |>
  select(realization, cri)  

saveRDS(glide_cri, here("tables", "tab_phase2_multi_cri.rds"))
saveRDS(glide_i_cri, here("tables", "tab_phase2_multi_i_cri.rds"))
saveRDS(glide_u_cri, here("tables", "tab_phase2_multi_u_cri.rds"))

# -----------------------------------------------------------------------------




# Plots -----------------------------------------------------------------------

p_multi_0 <- b_multi_0_post |> 
  ggplot() + 
  aes(x = phi, color = realization, fill = realization) + 
  stat_slab(alpha = 0.7, color = "white") +
  stat_pointinterval(
    aes(y = -0.025), 
    pch = 21, point_fill = "white", point_size = 4, show.legend = F, 
    position = position_dodge(width = .4, preserve = "single")
  ) +
  scale_fill_manual(name = NULL, values = my_colors, labels = NULL) + 
  scale_color_manual(name = NULL, values = my_colors, labels = NULL) + 
  coord_cartesian(ylim = c(-0.2, NA)) + 
  scale_x_continuous(
    labels = scales::percent, 
    expand = expansion(mult = c(0, 0)), limits = c(-0.0225, 1.02)
  ) + 
  labs(y = NULL, x = NULL) + 
  annotate("text", label = "(A)", x = 0, y = 0.95, family = "Times") + 
  annotate("text", label = "P(response)", x = 0.67, y = 0.9, size = 3.25) +
  annotate("text", x = c(0.65, 0.95), y = 0.65, hjust = c(0, 1), size = 3.25,
           family = "Times", label = glue::glue("
        {glide_cri[1, ]}
        {glide_cri[2, ]}
        {glide_cri[3, ]}")) +
  ds4ling::ds4ling_bw_theme(base_size = 13) + 
  theme(legend.position = c(0.63, 0.6875), 
        legend.spacing.y = unit(0, 'cm'), 
        legend.key.height = unit(0.5, "cm"),
        legend.background = element_blank(), 
        legend.key = element_rect(fill = NA), 
        strip.background = element_rect(fill = NA), 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())

p_multi_i <- b_multi_1a_post |> 
  ggplot() + 
  aes(x = phi, color = realization, fill = realization) + 
  stat_slab(alpha = 0.7, color = "white") +
  stat_pointinterval(
    aes(y = -0.025), 
    pch = 21, point_fill = "white", point_size = 4, 
    position = position_dodge(width = .4, preserve = "single"), 
    show.legend = F
  ) +
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
  ds4ling::ds4ling_bw_theme(base_size = 13) + 
  theme(legend.position = c(0.65, 0.7), 
        legend.spacing.y = unit(0, 'cm'), 
        legend.key.height = unit(0.5, "cm"),
        legend.background = element_blank(), 
        legend.key = element_rect(fill = NA), 
        strip.background = element_rect(fill = NA), 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())

p_multi_u <- b_multi_1b_post |> 
  ggplot() + 
  aes(x = phi, color = realization, fill = realization) + 
  stat_slab(alpha = 0.7, color = "white") +
  stat_pointinterval(
    aes(y = -0.025), 
    pch = 21, point_fill = "white", point_size = 4, 
    position = position_dodge(width = .4, preserve = "single"), 
    show.legend = F
  ) +
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
  ds4ling::ds4ling_bw_theme(base_size = 13) + 
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
  filename = "syllabification_phase2_all.png", 
  plot = syllabification_all, 
  path = here("figs", "manuscript"), width = 7, height = 5.75, dpi = 600
)

# -----------------------------------------------------------------------------




# Tables ----------------------------------------------------------------------

bind_rows(
  bayestestR::describe_posterior(
    posteriors = b_multi_0, test = "p_direction", 
    effects = "all", priors = T
    ) |>
    as_tibble() |> 
    mutate(Model = "Main"), 
  bayestestR::describe_posterior(
    posteriors = b_multi_1a, test = "p_direction", 
    effects = "all", priors = T
    ) |>
    as_tibble() |> 
    mutate(Model = "[j]"), 
  bayestestR::describe_posterior(
    posteriors = b_multi_1b, test = "p_direction", 
    effects = "all", priors = T) |>
    as_tibble() |> 
    mutate(Model = "[w]") 
) |> 
  mutate_if(is.numeric, specify_decimal, k = 2) |> 
  mutate(
    Parameter = str_replace_all(Parameter, "b_mu", "μ "), 
    Parameter = str_replace_all(Parameter, "_", ": "), 
    Prior = glue("{Prior_Distribution}(0, 20)"), 
    Prior = str_to_title(Prior), 
    Estimate = glue("{Median} [{CI_low}, {CI_high}]")) |> 
  select(Model, Parameter, Estimate, `P(direction)` = pd, Rhat, ESS, Prior) |> 
  saveRDS(file = here("tables", "tab_phase2_multi_all.rds"))

# -----------------------------------------------------------------------------










# -----------------------------------------------------------------------------
# 02122025
# Table for Phase_2
view(phase_2)

#color blind palette
cbPalette <- c("#000000","#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

# create rule for aligning Participant's response with Phase 1
phase_2_match <- phase_2 %>%
  mutate(match = common_response == response) %>%
  drop_na(match) %>%
  arrange(item) %>%
  group_by(item)

#subset with only diphthongs. Returns rows where op3 is NA

phase_2_diphthong <- phase_2_match %>%
  filter(is.na(op3)) %>%
  mutate(match = common_response == response,
  matched_option = case_when(
    response == op1~"diphthong",
    response == op2~"hiatus",
    TRUE ~"No Match"))

print(phase_2_diphthong)
table(phase_2_diphthong$match)

#
# FALSE  TRUE 
# 2202  3886 

## responses matched the diphthong, the hiatus or response was altered by participant

#distribution of responses

phase_2_diphthong %>%
  count(match,matched_option) %>%
  mutate(match = factor(match, levels = c("TRUE", "FALSE"))) %>%
  ggplot(aes(x = match, y = n, fill = match)) +
  stat_summary(fun="identity", geom = "bar", position= "dodge")+
  geom_col() +
  facet_wrap(~matched_option, scales = "free_x") +
  labs(x = "Phase 2 = phase 1 response?", y = "count") +
  theme(legend.position = "none") +
  scale_color_manual(values=cbPalette[c(3,4)]) +
  scale_fill_manual(values=cbPalette[c(3,4)]) +
  my_save("Phase2_Feb25/plot_response_diphthongs.png")


#subset with only triphthongs. Keeps only rows where op3 is NOT na

phase_2_triphthong <- phase_2_match %>%
  filter(!is.na(op3)) %>%
  mutate(match = common_response == response,
         matched_option = case_when(
           response == op1~"triphthong",
           response == op2~"FallingDiphthong",
           response == op3~"RisingDiphthong",
           TRUE ~"No Match")
  )

print(phase_2_triphthong)

#subset with only triphthongs
table(phase_2_triphthong$match)
#
#FALSE  TRUE 
#4074  6277 

## responses matched the triphthong, falling diphthong, rising diphthong or response was altered by participant

#distribution of responses

phase_2_triphthong %>%
  count(match,matched_option) %>%
  mutate(match = factor(match, levels = c("TRUE", "FALSE"))) %>%
  ggplot(aes(x = match, y = n, fill = match)) +
  stat_summary(fun="identity", geom = "bar", position= "dodge")+
  geom_col() +
  facet_wrap(~matched_option, scales = "free_x") +
  labs(x = "Phase 2 = phase 1 response?", y = "count") +
  theme(legend.position = "none") +
  scale_color_manual(values=cbPalette[c(3,4)]) +
  scale_fill_manual(values=cbPalette[c(3,4)]) +
  my_save("Phase2_Feb25/plot_response_triphthongs.png")


## order by item

phase_2_f <- phase_2 %>%
  mutate(match = common_response == response) %>%
  drop_na(match) %>%
  arrange(item) %>%
  group_by(item) %>%
  filter(match == "FALSE")


## exploring mismatches by items

phase_2_f %>%
  group_by(match, item) %>%
  count(match) %>%
  ggplot(aes(x=reorder(item,n), y=n, fill = n)) +
  geom_col() +
  coord_flip() +
  xlab("item") +
  scale_fill_gradient(low = "#009E73", high = "#CC79A7") +
  my_save("Phase2_Feb25/plot_response_mismatches.png")

