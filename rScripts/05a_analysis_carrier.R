# What are my questions?
# 1. Does duration vary as a function of preceding consonant?
# 2. Does the time course of F1 or intensity vary as a function of preceding 
#   consonant?
# How can I answer them?
# 1. linear mixed effects (dur ~ env)
# 2. gam (int ~ time course)

# Duration analysis -----------------------------------------------------------

# Get critical items
critical_items_tripthongs <- c(
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
  summarize(., dur = mean(duration)) %>% 
  ungroup(.) %>% 
  write_csv(., "./data/dataframes/tidy/carrier_duration_subset_tidy.csv")

dur_mod_full <- 
  lmer(dur ~ is_palatal + 
       (1 + is_palatal | participant) + 
       (1 | item), 
      data = carrier_dur_final)






# Time course of [j]: F1 ------------------------------------------------------

# set participant to factor
# set modality to ordered variable and relevel so production is reference
carrier_tc_final_gamm <- carrier_tc_final %>% 
  mutate(., participant = as.factor(participant), 
            is_palatal_ord = as.ordered(is_palatal), 
            is_palatal_ord = fct_relevel(is_palatal_ord, 'palatal'))

# dummy code is_palatal_ord
contrasts(carrier_tc_final_gamm$is_palatal_ord) <- "contr.treatment" 

if(F){
  # Fit full model with parametric is_palatal_ord variable, reference smooth,  
  # difference smooth, and random smooth
  f1_gam_1 <- gam(
    f1norm ~ is_palatal_ord +                                              # parametric predictor
           s(time_course_segment, bs = "cr", k = 3) +                      # reference smooth
           s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 3) + # difference smooth
           s(time_course_segment, participant, bs = "fs", xt = "cr", m = 1, k = 3), # random smooth
    data = carrier_tc_final_gamm, method = "ML") 

  # Fit null model with no parametric modality predictor nor difference smooth
  # Essentially take out anything related to voicing
  f1_gam_0 <- gam(
    f1norm ~ s(time_course_segment, bs = "cr", k = 3) +                               # reference smooth
             s(time_course_segment, participant, bs = "fs", xt = "cr", m = 1, k = 3), # random smooth
    data = carrier_tc_final_gamm, method = "ML") 

  #saveRDS(prod_gam_1, "./cache/prod_perc/time_course/prod_gam1.rds", compress = 'xz')
  #saveRDS(prod_gam_0, "./cache/prod_perc/time_course/prod_gam0.rds", compress = 'xz')
  }

## @knitr prod_gam_aov_table

# Nested model comparisons
compareML(f1_gam_1, f1_gam_0)

  plot_smooth(f1_gam_1, view = "time_course_segment",
              plot_all = "is_palatal_ord", rug = F, 
              col = c('darkred', 'darkblue'), xlab = "Time course", 
              ylab = "Standardized F1", legend_plot_all = "topleft", 
              hide.label = T, lwd = 2, rm.ranef = T, cex.axis = 1.5, 
              cex.lab = 1.5)


# Time course of [j]: Intensity ------------------------------------------------
carrier_tc_final_gamm <- carrier_tc_final_gamm %>% 
  mutate(., int_norm = (`in` - mean(`in`)) / sd(`in`))
  
  if(F){
  # Fit full model with parametric is_palatal_ord variable, reference smooth,  
  # difference smooth, and random smooth
  int_gam_1 <- gam(
    int_norm ~ is_palatal_ord +                                              # parametric predictor
           s(time_course_segment, bs = "cr", k = 3) +                      # reference smooth
           s(time_course_segment, by = is_palatal_ord, bs = "cr", k = 3) + # difference smooth
           s(time_course_segment, participant, bs = "fs", xt = "cr", m = 1, k = 3), # random smooth
    data = carrier_tc_final_gamm, method = "ML") 

  # Fit null model with no parametric modality predictor nor difference smooth
  # Essentially take out anything related to voicing
  int_gam_0 <- gam(
    int_norm ~ s(time_course_segment, bs = "cr", k = 3) +                               # reference smooth
             s(time_course_segment, participant, bs = "fs", xt = "cr", m = 1, k = 3), # random smooth
    data = carrier_tc_final_gamm, method = "ML") 

  #saveRDS(prod_gam_1, "./cache/prod_perc/time_course/prod_gam1.rds", compress = 'xz')
  #saveRDS(prod_gam_0, "./cache/prod_perc/time_course/prod_gam0.rds", compress = 'xz')
  }

  # Nested model comparisons
compareML(int_gam_1, int_gam_0)

  plot_smooth(int_gam_1, view = "time_course_segment",
              plot_all = "is_palatal_ord", rug = F, 
              col = c('darkred', 'darkblue'), xlab = "Time course", 
              ylab = "Standardized Intensity", legend_plot_all = "topleft", 
              hide.label = T, lwd = 2, rm.ranef = T, cex.axis = 1.5, 
              cex.lab = 1.5)

    plot_diff(int_gam_1, view = "time_course_segment",
            comp = list(is_palatal_ord = c("palatal", "other")), 
            col = 'darkblue', lwd = 2, rm.ranef = T, hide.label = T, 
            xlab = "Time course", 
            ylab = "Est. difference in std. intensity", cex.axis = 1.5, 
            cex.lab = 1.5, cex.main = 2)
    
