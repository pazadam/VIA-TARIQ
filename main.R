#########################################################################################################
### MODELLING NATURAL CORRIDORS OF MOVEMENT IN THE SOUTHERN LEVANT BASED ON THE ANALYSIS OF ROAD DATA ###
#########################################################################################################

#### THE AIM OF THIS CODE IS TO MODEL NATURAL CORRIDORS OF MVOEMENT IN THE SOUTHERN LEVNAT USING ADAPTED 'FROM EVERYWHERE TO EVERYWHERE' (FETE) METHOD 
#### IN THE FIRST SCENARIO, 2 ISOTROPIC CONDUCTANCE SURFACES USING TOPOGRPAHIC VARIABLES, CRITICAL SLOPE AND SLOPE CATEGORIES ARE USED
#### in THE SECOND SCENARIO, FETE LCPS ARE MODELLED USING SLOPE-BASED ALGORITHMS (TOBLER, NAISMITH, HERYOG, LLOBERA-SLUCKIN)

#Libraries
library(sf)
library(terra)
library(leastcostpath)
library(dplyr)
library(foreach)
library(tidyr)

#Number of simulation runs
n_sims <- 50

###Scenario 1.1 MODELLING FETE LCPS USING ISOTROPIC CONDUCTANCE SURFACE MORE SENSITIVE TO SLOPE AND TOPOGRAPHY (MODEL A)

#IMPORT DATA
cs_75_sl10_t02 <- terra::rast("data/raster/south_conductance_75_sl10_t02.tif")
b_box_south <- sf::st_read("data/vector/b_box_south.shp")

#CREATE ISOTROPIC CONDUCTIVITY SURFACE
cs <- leastcostpath::create_cs(x=cs_75_sl10_t02, neighbours = 16, dem = NULL, max_slope = NULL)

#CALCULATE FETE LCPS USING ISOTROPIC CONDUCTIVITY SURFACE AND RANDOM POINTS
#IN EACH RUN A SET OF 100 RANDOM POINTS WITHIN A BOUNDING BOX (EQUAL TO THE EXTENT OF THE UNDERLYING CONDUCTANCE SURFACE) ARE GENERATED
#POINTS AND LCPS ARE THEN EXPORTED AS SHAPEFILES TO USE IN THE GIS FOR ADDITIONAL ANALYSES

#Create empty lists to store the results
points_south75_sl10_t02 <- list()
fete_south75_sl10_t02 <- list()

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_south75_sl10_t02[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 100, type = "random"), crs = sf::st_crs(b_box_south))
  fete_south75_sl10_t02[[i]] <- leastcostpath::create_FETE_lcps(x = cs, locations = points_south75_sl10_t02[[i]])
  sf::write_sf(fete_south75_sl10_t02[[i]], paste0("outputs/fete_south75_sl10_t02_", i, ".shp"))
  sf::write_sf(points_south75_sl10_t02[[i]], paste0("outputs/points_south75_sl10_t02_", i, ".shp"))
}

###SCENARIO 1.2 MODELLING FETE LCPS USING ISOTROPIC CONDUCTANCE SURFACE LESS SENSITIVE TO SLOPE AND TOPOGRAPHY (MODEL B)

cs_75_sl20_t10 <- terra::rast("data/raster/south_conductance_75_sl20_t10.tif")

#Create isotropic conductance surface
cs2 <- leastcostpath::create_cs(x=cs_75_sl20_t10, neighbours = 16, dem = NULL, max_slope = NULL)

#CALCULATE FETE LCPS USING ISOTROPIC CONDUCTIVITY SURFACE AND RANDOM POINTS
#IN EACH RUN A SET OF 100 RANDOM POINTS WITHIN A BOUNDING BOX (EQUAL TO THE EXTENT OF THE UNDERLYING CONDUCTANCE SURFACE) ARE GENERATED
#POINTS AND LCPS ARE THEN EXPORTED AS SHAPEFILES TO USE IN THE GIS FOR ADDITIONAL ANALYSES

#Create empty lists to store the results
points_south75_sl20_t10 <- list()
fete_south75_sl20_t10 <- list()

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_south75_sl20_t10[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 100, type = "random"), crs = sf::st_crs(b_box_south))
  fete_south75_sl20_t10[[i]] <- leastcostpath::create_FETE_lcps(x = cs2, locations = points_south75_sl20_t10[[i]])
  sf::write_sf(fete_south75_sl20_t10[[i]], paste0("outputs/fete_south75_sl20_t10_", i, ".shp"))
  sf::write_sf(points_south75_sl20_t10[[i]], paste0("outputs/points_south75_sl20_t10_", i, ".shp"))
}

####SCENARIO 2 MODELLING FETE LCPS USING SLOPE-BASED ALGORITHMS

##Number of simulations
n_sims <- 10

#Import DEM
south_dem_75 <- terra::rast("data/raster/south_dem_75.tif")

###TOBLER'S FUNCTION

#Create lists to store the results
points_tobler <- list()
fete_tobler <- list()

#Create CS
cs_tobler <- leastcostpath::create_slope_cs(south_dem_75, cost_function = "tobler", neighbours = 16)

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_tobler[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 50, type = "random"), crs = sf::st_crs(b_box_south))
  fete_tobler[[i]] <- leastcostpath::create_FETE_lcps(x = cs_tobler, locations = points_tobler[[i]])
  sf::write_sf(fete_tobler[[i]], paste0("outputs/fete_tobler", i, ".shp"))
  sf::write_sf(points_tobler[[i]], paste0("outputs/points_tobler", i, ".shp"))
}

###NAIMSITH'S FUNCTION
points_naismith <- list()
fete_naismith <- list()

#Create CS
cs_naismith <- leastcostpath::create_slope_cs(south_dem_75, cost_function = "naismith", neighbours = 16)

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_naismith[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 50, type = "random"), crs = sf::st_crs(b_box_south))
  fete_naismith[[i]] <- leastcostpath::create_FETE_lcps(x = cs_naismith, locations = points_naismith[[i]])
  sf::write_sf(fete_naismith[[i]], paste0("outputs/fete_naismith", i, ".shp"))
  sf::write_sf(points_naismith[[i]], paste0("outputs/points_naismith", i, ".shp"))
}

###HERZOG'S FUNCTION
points_herzog <- list()
fete_herzog <- list()

#Create CS
cs_herzog <- leastcostpath::create_slope_cs(south_dem_75, cost_function = "herzog", neighbours = 16)

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_herzog[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 50, type = "random"), crs = sf::st_crs(b_box_south))
  fete_herzog[[i]] <- leastcostpath::create_FETE_lcps(x = cs_herzog, locations = points_herzog[[i]])
  sf::write_sf(fete_herzog[[i]], paste0("outputs/fete_herzog", i, ".shp"))
  sf::write_sf(points_herzog[[i]], paste0("outputs/points_herzog", i, ".shp"))
}

###LLOBERA-SLUCKIN'S FUNCTION
points_llobera <- list()
fete_llobera <- list()

#Create CS
cs_llobera <- leastcostpath::create_slope_cs(south_dem_75, cost_function = "llobera-sluckin", neighbours = 16)

for (i in 1:n_sims) {
  print(paste0("i = ", i))
  points_llobera[[i]] <- sf::st_as_sf(sf::st_sample(b_box_south, 50, type = "random"), crs = sf::st_crs(b_box_south))
  fete_llobera[[i]] <- leastcostpath::create_FETE_lcps(x = cs_llobera, locations = points_llobera[[i]])
  sf::write_sf(fete_llobera[[i]], paste0("outputs/fete_llobera", i, ".shp"))
  sf::write_sf(points_llobera[[i]], paste0("outputs/points_llobera", i, ".shp"))
}