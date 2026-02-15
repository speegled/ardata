dd <- readxl::read_xlsx(here::here("data_raw/body_ownership/dt2.noout.xlsx")) |> 
  janitor::clean_names()

body_ownership <- dd
save(body_ownership, file = "data/body_ownership.rda")
