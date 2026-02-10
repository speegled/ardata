#'
#' Run sym-analysis.Rmd through line 494
#'

beethoven_tempos <- dt.window |> 
  janitor::clean_names()

save(beethoven_tempos, file = "data/beethoven_tempos.rda")
