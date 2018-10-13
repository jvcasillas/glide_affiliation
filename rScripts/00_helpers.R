# Load libraries
library(tidyverse)
library(here)
library(broom)
library(lme4)
library(lmerTest)
library(knitr)
library(kableExtra)
library(patchwork)
library(brms)
library(tidybayes)
library(mgcv)
library(itsadug)
library(voxel)

library(modelr)
library(ggstance)
library(ggridges)
library(cowplot)
library(rstan)
library(ggrepel)

# Plotting functions ----------------------------------------------------------

## create style theme
my_theme <- function() {
  theme_minimal() + 
    theme(
      plot.title = element_text(size = rel(1.5), face = "bold"), 
      plot.subtitle = element_text(size = rel(1.1)),
      plot.caption = element_text(color = "#777777", vjust = 0),
      axis.title = element_text(size = rel(.9), hjust = 0.95, face = "italic"), 
      panel.grid.major = element_line(size = rel(.1), color = "#000000"), 
      panel.grid.minor = element_line(size = rel(.05), color = "#000000")
    )
}

my_save <- function(file) {
  ggsave(file, width = 7, height = 4.5, units = "in")
}

