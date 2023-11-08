source(here::here("scripts", "r", "00_helpers.R"))


dir_ls(here("data", "phase_2"), regexp = ".csv") |> 
  read_csv()

