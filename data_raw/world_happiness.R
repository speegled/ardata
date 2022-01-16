ww <- readxl::read_xls("data_raw/world_happiness_data.xls")
ww <- janitor::clean_names(ww)
names(ww)
summary(ww)

world_happiness <- select(ww, -matches("standa"))
save(world_happiness, file = "data/world_happiness.rda")