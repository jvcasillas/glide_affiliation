# Load libraries --------------------------------------------------------------

library("tidyverse")
library("here")
library("broom")
library("knitr")
library("kableExtra")
library("patchwork")
library("brms")
library("tidybayes")
library("modelr")

# -----------------------------------------------------------------------------




# Plotting functions ----------------------------------------------------------

# create style theme
my_theme <- function(...) {
  list(
    theme_minimal(...), 
    theme(
      plot.title = element_text(size = rel(1.5), face = "bold"), 
      plot.subtitle = element_text(size = rel(1.1)),
      plot.caption = element_text(color = "#777777", vjust = 0),
      axis.title = element_text(size = rel(.9), hjust = 0.95), 
      panel.grid.major = element_line(size = 0.15, color = "grey90"), 
      panel.grid.minor = element_line(size = 0.15, color = "grey90"))
  )
}

my_empty <- function(...) {
  list(
    theme_minimal(...), 
    theme(
      plot.title = element_text(size = rel(1.5), face = "bold"), 
      plot.subtitle = element_text(size = rel(1.1)),
      plot.caption = element_text(color = "#777777", vjust = 0),
      axis.title = element_text(size = rel(.9), hjust = 0.95), 
      panel.grid.major = element_line(size = 0, color = "grey90"), 
      panel.grid.minor = element_line(size = 0, color = "grey90"))
  )
}

# Quick save function
my_save <- function(file) {
  ggsave(file, width = 7, height = 4.5, units = "in")
}

# Viridis colors (colorblindness friendly)
my_colors <- c("#f98e09", "#bc3754", "#57106e")

# -----------------------------------------------------------------------------


# Other helpers ---------------------------------------------------------------

specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))

# -----------------------------------------------------------------------------
