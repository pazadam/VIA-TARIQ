############################################################################################
#MODELLING NATURAL CORRIDORS OF MOVEMENT IN THE LEVANT BASED ON ANALYSIS OF ROMAN ROAD DATA#
############################################################################################

#LOAD LIBRARIES
library(sf)
library(terra)
library(leastcostpath)
library(dplyr)
library(tmap)
library(foreach)
library(tidyverse)
library(ggplot2)

#SET UP NUMBER OF SIMULATIONS
n_sims <- 50

###SCENARIO 1: MODELLING NATURAL CORRIDORS OF MOVEMENT USING FETE WITH RANDOM POINTS

#IMPORT DATA
cost <- terra::rast("data/levant_conductance_250.tif")
b_box <- sf::st_read("data/b_box.shp")

#CREATE ISOTROPIC CONDUCTANCE SURFACE
cs_250 <- leastcostpath::create_cs(x = cost, neighbours = 16, dem = NULL, max_slope = NULL) #USING NEIGHBOURS=16 WHICH IS EQUAL TO KNIGHT'S MOVE

# INITIALISE LISTS TO STORE FETE RESULTS
fete_random <- list()
random_points <- list()

#MODELLING FETE LCPS
#IN EACH RUN A SET OF 100 RANDOM POINTS WITHIN A BOUNDING BOX (EQUAL TO THE EXTENT OF THE UNDERLYING CONDUCTANCE SURFACE) ARE GENERATED
#LCPS ARE THEN CALCULATED FROM ALL POINTS TO ALL OTHER POINTS (FETE=FROM EVERYWHERE TO EVERYWHERE)#
#POINTS AND LCPS ARE THEN EXPORTED AS SHAPEFILES TO USE IN THE GIS FOR ADDITIONAL ANALYSES
for (i in 1:n_sims) {
  print(paste0("i = ", i))
  random_points[[i]] <- sf::st_as_sf(sf::st_sample(b_box, 100, type = "random"), crs = sf::st_crs(b_box))
  fete_random[[i]] <- leastcostpath::create_FETE_lcps(x = cs_250, locations = random_points[[i]])
  sf::write_sf(fete_random[[i]], paste0("outputs/fete_random_", i, ".shp"))
  sf::write_sf(random_points[[i]], paste0("outputs/random_points_", i, ".shp"))
}

###SCENARIO 2: MODELLING FETE LCPS IN THE SOUTHERN LEVANT AND COMPARING VARIOUS COST FUNCTIONS

##IMPORT DATA
dem_70 <- terra::rast("data/south_dem_70.tif")
cs_70 <- terra::rast("data/south_conductance_70.tif")
source_points <- sf::st_read("data/south_source_points.shp")
south_sites <- sf::st_read("data/south_sites.shp")

#CREATE ISOTROPIC CONDUCTIVITY SURFACE
cs <- leastcostpath::create_cs(x=cs_70, neighbours = 16, dem = NULL, max_slope = NULL)

#CALCULATE FETE LCPS USING ISOTROPIC CONDUCTIVITY SURFACE FOR A REGULAR GRID OF POINTS
south_fete <- leastcostpath::create_FETE_lcps(x=cs, locations = source_points, cost_distance = FALSE, ncores = 1)
sf::st_write(south_fete, "outputs/south_fete.shp")

#CALCULATE FETE LCPS USING ISOTROPIC CONDUCTIVITY SURFACE FOR SELECTED ROMAN SITES
south_roman <- leastcostpath::create_FETE_lcps(x=cs, locations = south_sites, cost_distance = FALSE, ncores = 1)
sf::st_write(south_roman, "outputs/south_roman.shp")

##MODELLING FETE LCPS USING DIFFERENT COST FUNCTIONS

#DEFINE COST FUNCTIONS
cost_functions <- c("tobler", "naismith", "herzog", "llobera-sluckin") #TOBLER AND NAISMITH FUNCTIONS ARE TIME-SAVING ALGORITHMS, HERZOG AND LLOBERA-SLUCKIN ARE ENERGY-SAVING FUNCTIONS

#INITIALISE A LIST TO STORE RESULTING FETE LCPS FOR DEFINED COST FUNCTIONS
slope_fete <- list()

#CALCULATE FETE LCPS FOR EACH DEFINED SLOPE FUNCTION USING REGULAR GRID OF POINTS
for (i in 1:length(cost_functions)) {
  print(paste0("i = ", i))
  print("calculating conductivity surface")
  cs_slope <- leastcostpath::create_slope_cs(x = dem_70, cost_function = cost_functions[i], neighbours = 16)
  print("calculating fete")
  slope_fete[[i]] <- leastcostpath::create_FETE_lcps(x = cs_slope, locations = source_points, cost_distance = FALSE, ncores = 1)
  sf::write_sf(slope_fete[[i]], paste0("outputs/", cost_functions[i], ".shp"))
  
}

#INITIALISE A LIST TO STORE RESULTING FETE LCPS FOR DEFINED COST FUNCTIONS
slope_fete_roman <- list()

#CALCULATE FETE LCPS FOR EACH DEFINED SLOPE FUNCTION USING ROMAN SITES
for (i in 1:length(cost_functions)) {
  print(paste0("i = ", i))
  print("calculating conductivity surface")
  cs_slope <- leastcostpath::create_slope_cs(x = dem_70, cost_function = cost_functions[i], neighbours = 16)
  print("calculating fete")
  slope_fete_roman[[i]] <- leastcostpath::create_FETE_lcps(x = cs_slope, locations = south_sites, cost_distance = FALSE, ncores = 1)
  sf::write_sf(slope_fete_roman[[i]], paste0("outputs/", cost_functions[i], "_roman", ".shp"))
  
}

##COMPARING FETE LCPS (ISOTROPIC MODEL WITH DEFINED COST FUNCTIONS), REGULAR GRID OF POINTS#

#SEPARATE FETE LCPS ACCORDING TO THE SLOPE FUNCTION USED
tobler <- slope_fete[[1]]
naismith <- slope_fete[[2]]
herzog <- slope_fete[[3]]
llobera_sluckin <- slope_fete[[4]]

#TOBLER PDI VALIDATION
tobler_PDIs <- list()

tobler_ids <- tobler %>%
  st_drop_geometry() %>%
  select(origin_ID, destination_ID) %>%
  distinct()

south_fete_ids <- south_fete %>%
  st_drop_geometry() %>%
  select(origin_ID, destination_ID) %>%
  distinct()

tobler_common <- inner_join(tobler_ids, south_fete_ids, by = c("origin_ID", "destination_ID"))

for (i in 1:nrow(tobler_common)) {
  origin_ <- tobler_common$origin_ID[i]
  destination <- tobler_common$destination_ID[i]
  
  subset_tobler <- tobler %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_south_fete <- south_fete %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  tobler_pdi_results <- leastcostpath::PDI_validation(lcp = subset_tobler, comparison = subset_south_fete)
  
  tobler_PDIs[[paste(origin_, destination, sep = "_")]] <- tobler_pdi_results
  
}

tobler_PDI_validation <- do.call(rbind, tobler_PDIs)
sf::st_write(tobler_PDI_validation, "outputs/tobler_PDI_validation.shp")

#NAISMITH PDI VALIDATION
naismith_PDIs <- list()

for (i in 1:nrow(south_fete_ids)) {
  origin_ <- south_fete_ids$origin_ID[i]
  destination <- south_fete_ids$destination_ID[i]
  
  subset_naismith <- naismith %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_south_fete <- south_fete %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  naismith_pdi_results <- leastcostpath::PDI_validation(lcp = subset_naismith, comparison = subset_south_fete)
  
  naismith_PDIs[[paste(origin_, destination, sep = "_")]] <- naismith_pdi_results
  
}

naismith_PDI_validation <- do.call(rbind, naismith_PDIs)
sf::st_write(naismith_PDI_validation, "outputs/naismith_PDI_validation.shp")

#HERZOG PDI VALIDATION
herzog_PDIs <- list()

for (i in 1:nrow(south_fete_ids)) {
  origin_ <- south_fete_ids$origin_ID[i]
  destination <- south_fete_ids$destination_ID[i]
  
  subset_herzog <- herzog %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_south_fete <- south_fete %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  herzog_pdi_results <- leastcostpath::PDI_validation(lcp = subset_herzog, comparison = subset_south_fete)
  
  herzog_PDIs[[paste(origin_, destination, sep = "_")]] <- herzog_pdi_results
  
}

herzog_PDI_validation <- do.call(rbind, herzog_PDIs)
sf::st_write(herzog_PDI_validation, "outputs/herzog_PDI_validation.shp")

#LLOBERA-SLUCKIN PDI VALIDATION
llobera_PDIs <- list()

for (i in 1:nrow(south_fete_ids)) {
  origin_ <- south_fete_ids$origin_ID[i]
  destination <- south_fete_ids$destination_ID[i]
  
  subset_llobera <-llobera_sluckin %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_south_fete <- south_fete %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  llobera_pdi_results <- leastcostpath::PDI_validation(lcp = subset_llobera, comparison = subset_south_fete)
  
  llobera_PDIs[[paste(origin_, destination, sep = "_")]] <- llobera_pdi_results
  
}

llobera_PDI_validation <- do.call(rbind, llobera_PDIs)
sf::st_write(llobera_PDI_validation, "outputs/llobera_PDI_validation.shp")

#COMPARE NORMALISED PDI VALUES
tobler_rom_npdi <- tobler_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_tobler = normalised_pdi) %>%
  select(n_pdi_tobler) %>%
  distinct()

naismith_npdi <- naismith_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_naismith = normalised_pdi) %>%
  select(n_pdi_naismith) %>%
  distinct()

herzog_npdi <- herzog_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_herzog = normalised_pdi) %>%
  select(n_pdi_herzog) %>%
  distinct()

llobera_npdi <- llobera_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_llobera = normalised_pdi) %>%
  select(n_pdi_llobera) %>%
  distinct()

npdi_comparison <- cbind(tobler_npdi, naismith_npdi, herzog_npdi, llobera_npdi)

npdi_comparison_long <- npdi_comparison %>%
  pivot_longer(cols = everything(), names_to = "Columns", values_to = "Values")

#PLOT THE RESULTS
ggplot(npdi_comparison_long, aes(x=Columns, y=Values, fill = Columns)) +
  geom_boxplot(alpha=0.7)+
  stat_summary(fun.y = mean, geom = "point", shape = 4, size=4, color="black")+
  theme(legend.position = "none", axis.text.x = element_text(), axis.title.x = element_blank())+
  scale_fill_brewer(palette = "Set1")

##COMPARING ISOTROPIC AND SLOPE-BASED FETE LCPS (WITH ROMAN SITES AS SOURCE POINTS) TO SELECTED ROMAN ROADS

#IMPORT ROMAN ROADS
roman_roads <- st_read("data/south_case_roads.shp")

names(roman_roads)[names(roman_roads) == "origin"] <- "origin_ID"  #RENAME FIELDS TO origin_ID AND destination_ID SO THEY ARE IDENTICAL TO OTHER DATA FRAMES
names(roman_roads)[names(roman_roads) == "destinatio"] <- "destination_ID"

roman_roads <- st_zm(roman_roads, drop=TRUE, what = "ZM") #DROP Z DIMENSION AS ALL DATA FRAMES HAVE ONLY XY

#SEPARATE SLOPE-BASED FETE LCPS 
tobler_roman <- slope_fete_roman[[1]]
naismith_roman <- slope_fete_roman[[2]]
herzog_roman <- slope_fete_roman[[3]]
llobera_sluckin_roman <- slope_fete_roman[[4]]

#SET COMMON PROJECTED COORDINATE SYSTEM
south_roman <- st_transform(south_roman, st_crs(roman_roads))
tobler_roman <- st_transform(tobler_roman, st_crs(roman_roads))
naismith_roman <- st_transform(naismith_roman, st_crs(roman_roads))
herzog_roman <- st_transform(herzog_roman, st_crs(roman_roads))
llobera_sluckin_roman <- st_transform(llobera_sluckin_roman, st_crs(roman_roads))

#FIND AND SEPARATE SELECTED CONNECTIONS FROM THE ROMAN ROADS DATASET
roman_roads_ids <- roman_roads %>%
  st_drop_geometry() %>%
  select(origin, destinatio) %>% 
  rename(origin_ID = origin, destination_ID = destinatio) %>%
  distinct()

south_roman_ids <- south_roman %>%
  st_drop_geometry() %>%
  select(origin_ID, destination_ID) %>%
  distinct()

iso_common <- inner_join(south_roman_ids, roman_roads_ids, by = c("origin_ID", "destination_ID")) #DATA FRAME CONTAINING COMMON ORIGIN AND DESTINATION IDS

#COMPARE ISOTROPIC MODEL LCPS WITH ROMAN ROADS
iso_roman_PDIs <- list()

for (i in 1:nrow(iso_common)) {
  origin_ <- iso_common$origin_ID[i]
  destination <- iso_common$destination_ID[i]
  
  subset_iso <- south_roman %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_roman_roads <- roman_roads %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  iso_roman_pdi_results <- leastcostpath::PDI_validation(lcp = subset_iso, comparison = subset_roman_roads)
  
  iso_roman_PDIs[[paste(origin_, destination, sep = "_")]] <- iso_roman_pdi_results
  
}

iso_roman_PDI_validation <- do.call(rbind, iso_roman_PDIs)
sf::st_write(iso_roman_PDI_validation, "outputs/iso_roman_PDI_validation.shp")

#COMPARE TOBLER LCPS WITH ROMAN ROADS
tobler_roman_PDIs <- list()

for (i in 1:nrow(iso_common)) {
  origin_ <- iso_common$origin_ID[i] #WE CAN USE ISO_COMMON BECAUSE THE ORIGIN AND DESTINATION IDS ARE THE SAME
  destination <- iso_common$destination_ID[i]
  
  subset_tobler_rom <- tobler_roman %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_roman_roads <- roman_roads %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  tobler_roman_pdi_results <- leastcostpath::PDI_validation(lcp = subset_tobler_rom, comparison = subset_roman_roads)
  
  tobler_roman_PDIs[[paste(origin_, destination, sep = "_")]] <- tobler_roman_pdi_results
  
}

tobler_roman_PDI_validation <- do.call(rbind, tobler_roman_PDIs)
sf::st_write(tobler_roman_PDI_validation, "outputs/tobler_roman_PDI_validation.shp")

#COMPARE NAISMITH LCPS WITH ROMAN ROADS
naismith_roman_PDIs <- list()

for (i in 1:nrow(iso_common)) {
  origin_ <- iso_common$origin_ID[i]
  destination <- iso_common$destination_ID[i]
  
  subset_naismith_rom <- naismith_roman %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_roman_roads <- roman_roads %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  naismith_roman_pdi_results <- leastcostpath::PDI_validation(lcp = subset_naismith_rom, comparison = subset_roman_roads)
  
  naismith_roman_PDIs[[paste(origin_, destination, sep = "_")]] <- naismith_roman_pdi_results
  
}

naismith_roman_PDI_validation <- do.call(rbind, naismith_roman_PDIs)
sf::st_write(naismith_roman_PDI_validation, "outputs/naismith_roman_PDI_validation.shp")

#COMPARE HERZOG LCPS WITH ROMAN ROADS
herzog_roman_PDIs <- list()

for (i in 1:nrow(iso_common)) {
  origin_ <- iso_common$origin_ID[i]
  destination <- iso_common$destination_ID[i]
  
  subset_herzog_rom <- herzog_roman %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_roman_roads <- roman_roads %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  herzog_roman_pdi_results <- leastcostpath::PDI_validation(lcp = subset_herzog_rom, comparison = subset_roman_roads)
  
  herzog_roman_PDIs[[paste(origin_, destination, sep = "_")]] <- herzog_roman_pdi_results
  
}

herzog_roman_PDI_validation <- do.call(rbind, herzog_roman_PDIs)
sf::st_write(herzog_roman_PDI_validation, "outputs/herzog_roman_PDI_validation.shp")

#COMPARE LLOBERA-SLUCKIN LCPS WITH ROMAN ROADS
llobera_roman_PDIs <- list()

for (i in 1:nrow(iso_common)) {
  origin_ <- iso_common$origin_ID[i]
  destination <- iso_common$destination_ID[i]
  
  subset_llobera_rom <- llobera_sluckin_roman %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  subset_roman_roads <- roman_roads %>%
    filter(origin_ID == !!origin_ & destination_ID == !!destination)
  
  llobera_roman_pdi_results <- leastcostpath::PDI_validation(lcp = subset_llobera_rom, comparison = subset_roman_roads)
  
  llobera_roman_PDIs[[paste(origin_, destination, sep = "_")]] <- llobera_roman_pdi_results
  
}

llobera_roman_PDI_validation <- do.call(rbind, llobera_roman_PDIs)
sf::st_write(llobera_roman_PDI_validation, "outputs/llobera_roman_PDI_validation.shp")

#COMPARE NORMALISED PDI VALUES
iso_rom_npdi <- iso_roman_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_iso = normalised_pdi) %>%
  select(n_pdi_iso) %>%
  distinct()

tobler_rom_npdi <- tobler_roman_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_tobler = normalised_pdi) %>%
  select(n_pdi_tobler) %>%
  distinct()

naismith_rom_npdi <- naismith_roman_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_naismith = normalised_pdi) %>%
  select(n_pdi_naismith) %>%
  distinct()

herzog_rom_npdi <- herzog_roman_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_herzog = normalised_pdi) %>%
  select(n_pdi_herzog) %>%
  distinct()

llobera_rom_npdi <- llobera_roman_PDI_validation %>%
  st_drop_geometry() %>%
  rename(n_pdi_llobera = normalised_pdi) %>%
  select(n_pdi_llobera) %>%
  distinct()

npdi_rom_comparison <- cbind(iso_rom_npdi, tobler_rom_npdi, naismith_rom_npdi, herzog_rom_npdi, llobera_rom_npdi)

npdi_rom_comparison_long <- npdi_rom_comparison %>%
  pivot_longer(cols = everything(), names_to = "Columns", values_to = "Values")

#PLOT THE RESULTS
ggplot(npdi_rom_comparison_long, aes(x=Columns, y=Values, fill = Columns)) +
  geom_boxplot(alpha=0.7)+
  stat_summary(fun.y = mean, geom = "point", shape = 4, size=4, color="black")+
  theme(legend.position = "none", axis.text.x = element_text(), axis.title.x = element_blank())+
  scale_fill_brewer(palette = "Set1")