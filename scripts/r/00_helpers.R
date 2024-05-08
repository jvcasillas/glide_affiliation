# Load libraries --------------------------------------------------------------

library("tidyverse")
library("here")
library("glue")
library("broom.mixed")
library("knitr")
library("kableExtra")
library("patchwork")
library("brms")
library("tidybayes")
library("modelr")
library("fs")

# -----------------------------------------------------------------------------




# Project-level functions -----------------------------------------------------

# Gitlab data
get_data_from_gitlab <- function(
    url, 
    zip_file_name = "ga_syllabified_check.zip", 
    destination = "phase_2" 
) {
  
  message("Checking for 'temp' directory")
  # Create temp directory if it doesn't exist
  if (!dir.exists(file.path(here("data", "temp")))) { 
    message("'temp' directory not found... creating it.")
    dir.create(file.path(here("data", "temp"))) 
  } else {
    message("'temp' directory already exists.")
  }

  # Download experiment zip file
  message("Downloading repo as zip file...")
  download.file(
    url = url, 
    destfile = glue("{here('data', 'temp')}/{zip_file_name}")
  )
  
  # Unzip files
  message("Unzipping files...")
  unzip(
    zipfile = glue("{here('data', 'temp')}/{zip_file_name}"), 
    junkpaths = TRUE, 
    exdir = here("data", "temp")
  )
  
  # Get df of all unzipped files
  all_files <- dir_ls(path = here("data", "temp")) |> 
    as_tibble()
  
  # Get vector of csv data files
  data_files_to_keep <- 
    dir_ls(path = here("data", "temp"), regexp = ".csv") |> 
    as_tibble() |> 
    filter(!(value %in% c(
        here("data", "temp", "p03_syllabified.csv"),
        here("data", "temp", "p04_syllabified.csv"),
        here("data", "temp", "p05_syllabified.csv"),
        here("data", "temp", "p06_syllabified.csv"),
        here("data", "temp", "p07_syllabified.csv"),
        here("data", "temp", "p08_syllabified.csv"),
        here("data", "temp", "practice_list.csv"),
        here("data", "temp", "trial_list.csv")
      )
     )
    ) |>
    pull()

  # Move data files to new directory
  message("Moving data files to appropriate directory...")
  file.rename(
    from = data_files_to_keep, 
    to = str_replace_all(data_files_to_keep, "temp", destination)
  )
  
  # Clear out 'temp' directory and leave receipts
  message("Cleaning up...")
  file.remove(
    c(
      dir_ls(path = here("data", "temp")), 
      here("data", "temp", ".gitignore")
    )
  )
  
  new_readme <- glue("{here('data', destination)}/README.md")
  file.create(new_readme)
  writeLines(
    text = c(
      glue("GA {destination} data last downloaded on {Sys.time()}"), 
      glue("{length(data_files_to_keep)} files moved to data/{destination}")
    ), 
    con = new_readme
  )
  
  # Delete temp folder
  message("Deleting temp directory")
  dir_delete(here("data", "temp"))
  
  message(c(
    "Finished.  ", 
    glue("{length(data_files_to_keep)} files moved to data/{destination}")
  )
  )
  
}

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


# Report posterior estimates and CIs
report_posterior <- function(df, row = NULL, param) {

  if (is.null(row)) {
    # Extract wanted value from model output
    est  <- df[df$Parameter == param, "Estimate"]
    mpe  <- df[df$Parameter == param, "P(direction)"]
  } else {
    # Extract wanted value from model output
    est  <- df[row, "Estimate"]
    mpe  <- df[row, "P(direction)"]
  }

  capture.output(
    paste0("(&beta; = ", est, "; MPE = ", mpe, ")", "\n") %>%
      cat()) %>%
    paste()

}

# -----------------------------------------------------------------------------
