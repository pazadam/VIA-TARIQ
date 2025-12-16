##################################################
#### TEST CASE: ASSIGNING CONDUCTIVITY VALUES ####
##################################################

### THE AIM OF THIS CODE IS TO TEST VARIOUS CONDUCTIVITY VALUES AND THEIR COMBINATIONS IN MODELLING KNOWN ROMAN ROADS
### THE PERFORMANCE OF EACH SET OF CONDUCTANCE SURFACES IS EVALUATED BY COMPARING THE KNOWN ROADS WITH MODELLED LCPS USING NORMALIZED PATH DEVIATION INDEX (NPDI).

#Libraries
library(sf)
library(terra)
library(leastcostpath)
library(ggplot2)
library(tidyr)
library(dplyr)

###Import data
#Site data (Emmaus, Lydda, Jerusalem for which LCPs will be modelled)
sites <- sf::st_read("data/vector/sites_evaluation.shp")

#Road data (for NPDI validation)
jr_lyd <- sf::st_read("data/vector/jerusalem-lydda.shp")
jr_em <- sf::st_read("data/vector/jerusalem-emmaus.shp")
em_lyd <- sf::st_read("data/vector/emmaus-lydda.shp")

jr_lyd <- st_zm(jr_lyd, drop = TRUE, what = "ZM")
jr_em <- st_zm(jr_em, drop = TRUE, what = "ZM")
em_lyd <- st_zm(em_lyd, drop = TRUE, what = "ZM")

##Conductance rasters

#VRML+TPI rasters
vrml_tpi_01 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_01.tif")
vrml_tpi_02 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_02.tif")
vrml_tpi_05 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_05.tif")
vrml_tpi_10 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_10.tif")
vrml_tpi_20 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_20.tif")
vrml_tpi_50 <- terra::rast("data/raster/vrml_tpi_cond/vrml_tpi_50.tif")

#Critical slope rasters
sl_90 <- terra::rast("data/raster/slope_cond/slope_90.tif")
sl_50 <- terra::rast("data/raster/slope_cond/slope_50.tif")
sl_30 <- terra::rast("data/raster/slope_cond/slope_30.tif")
sl_20 <- terra::rast("data/raster/slope_cond/slope_20.tif")
sl_10 <- terra::rast("data/raster/slope_cond/slope_10.tif")
sl_05 <- terra::rast("data/raster/slope_cond/slope_05.tif")

###CS lists
topo_list <- list(
  topo_01 = vrml_tpi_01,
  topo_02 = vrml_tpi_02,
  topo_05 = vrml_tpi_05,
  topo_10 = vrml_tpi_10,
  topo_20 = vrml_tpi_20,
  topo_50 = vrml_tpi_50
)

slope_list <- list(
  sl_05 = sl_05,
  sl_10 = sl_10,
  sl_20 = sl_20,
  sl_30 = sl_30,
  sl_50 = sl_50,
  sl_90 = sl_90
)

###Site pairs (create site pairs)
pairs <- t(combn(1:nrow(sites), 2))

###Calculate LCPs for Topo variables
#List to store results
lcp_topo <- list()

for (cs_name in names(topo_list)) {
  cat("Processing", cs_name, "...\n")
  
  r <- topo_list[[cs_name]]
  
  #Create conductivity surface
  cs <- create_cs(x = r, neighbours = 16)
  
  #Compute LCPs for each pair of points
  lcp_list <- list()
  
  for (i in seq_len(nrow(pairs))) {
    from <- sites[pairs[i, 1], ]
    to   <- sites[pairs[i, 2], ]
    
    lcp <- create_lcp(cs, origin = from, destination = to)
    
    #Annotate LCPs with metadata
    lcp$surface <- cs_name
    lcp$origin_ID <- pairs[i, 1]
    lcp$destination_ID <- pairs[i, 2]
    
    lcp_list[[i]] <- lcp
  }
  
  #Combine LCPs for each surface
  lcp_topo[[cs_name]] <- do.call(rbind, lcp_list)
}

##Export
for (cs_name in names(lcp_topo)) {
  lcp_sf <- lcp_topo[[cs_name]]
  
  filename <- paste0("outputs/LCP_", cs_name, ".shp")
  st_write(lcp_sf, filename, append = FALSE)
}

###NPDI validation for topo variables
#List of roads
roads <- list(
  "1_2" = jr_em,
  "1_3" = em_lyd,
  "2_3" = jr_lyd
)

cs_names <- names(lcp_topo)
road_names <- names(roads)

#Empty dataframe to store the results
topo_NPDI_results_df <- data.frame(matrix(NA_real_, nrow = length(cs_names), ncol = length(road_names)))
rownames(topo_NPDI_results_df) <- cs_names
colnames(topo_NPDI_results_df) <- road_names

#Define PDI_validation function. Original PDI_validation function in leastcostpath package does not correctly close polygons, the following fix is more explicit and works without problems.
PDI_validation_new <- function(lcp, comparison) {
  
  #Ensure planar CRS for area calculation
  if (sf::st_is_longlat(lcp)) {
    stop("Please project data to a planar CRS (e.g., EPSG:3395) before using PDI_validation.")
  }
  
  lcps <- list(lcp, sf::st_reverse(lcp))
  
  diff_polygons <- lapply(lcps, function(x) {
    #Extract coordinates
    coords_lcp <- sf::st_coordinates(x)
    coords_cmp <- sf::st_coordinates(comparison)
    
    #Force shared endpoints
    coords_lcp[1, ] <- coords_cmp[1, ]
    coords_lcp[nrow(coords_lcp), ] <- coords_cmp[nrow(coords_cmp), ]
    
    #Combine and explicitly close the polygon
    combined <- rbind(coords_lcp, coords_cmp, coords_lcp[1, ])
    
    diff_polygon <- sf::st_polygon(list(combined)) |> sf::st_sfc(crs = sf::st_crs(comparison))
    
    diff_polygon <- sf::st_make_valid(sf::st_zm(diff_polygon))
    
    area <- as.numeric(sf::st_area(diff_polygon))
    maxdist <- as.numeric(sf::st_distance(
      sf::st_point(coords_cmp[1, 1:2]),
      sf::st_point(coords_cmp[nrow(coords_cmp), 1:2])
    ))
    
    pdi <- area / maxdist
    npdi <- (pdi / maxdist) * 100
    
    sf::st_sf(
      area = area,
      pdi = pdi,
      normalised_pdi = npdi,
      geometry = diff_polygon
    )
  })
  
  diff_polygons[[which.min(sapply(diff_polygons, \(x) x$area))]]
}

#Loop through LCPs for each CS and calculate NPDI
for (cs_name in cs_names) {
  cat("Processing surface:", cs_name, "\n")
  
  lcp_sf <- lcp_topo[[cs_name]]
  
  for (road_name in road_names) {
    ids <- strsplit(road_name, "_")[[1]]
    from_id <- as.numeric(ids[1])
    to_id   <- as.numeric(ids[2])
    
    #Match the correct LCP by origin and destination IDs
    lcp_sel <- subset(lcp_sf, origin_ID == from_id & destination_ID == to_id)
    
    if (nrow(lcp_sel) == 0) {
      warning("No LCP found for road ", road_name, " in surface ", cs_name)
      next
    }
    
    road_sf <- roads[[road_name]]
    
    #Calculate NPDI, The function returns a dataframe
    pdi_result <- PDI_validation_new(lcp_sel, road_sf)
    
    #Extract NPDI values
    topo_NPDI_results_df[cs_name, road_name] <- pdi_result$normalised_pdi
  }
}

write.csv2(topo_NPDI_results_df, "outputs/topo_NPDI.csv")

##Plot topo NPDI
topo_NPDI_results_df$conductivity_surface <- rownames(topo_NPDI_results_df)

npdi_topo_long <- topo_NPDI_results_df %>%
  pivot_longer(
    cols = -conductivity_surface,
    names_to = "road",    #road names
    values_to = "NPDI"
  )

ggplot(npdi_topo_long, aes(x = conductivity_surface, y = NPDI, color = road, group = road)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(
    title = "NPDI values (topographic costs)",
    x = "Conductivity Surface",
    y = "NPDI",
    color = "Road"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # tilt x labels
  )

###Calculate LCPs for critical slope
#List to store results
lcp_slope <- list()

for (cs_name in names(slope_list)) {
  cat("Processing", cs_name, "...\n")
  
  r <- slope_list[[cs_name]]
  
  #Create conductivity surface
  cs <- create_cs(x = r, neighbours = 16)
  
  #Compute LCPs for each pair of points
  lcp_list <- list()
  
  for (i in seq_len(nrow(pairs))) {
    from <- sites[pairs[i, 1], ]
    to   <- sites[pairs[i, 2], ]
    
    lcp <- create_lcp(cs, origin = from, destination = to)
    
    #Annotate LCP with metadata
    lcp$surface <- cs_name
    lcp$origin_ID <- pairs[i, 1]
    lcp$destination_ID <- pairs[i, 2]
    
    lcp_list[[i]] <- lcp
  }
  
  #Combine LCPs for each surface
  lcp_slope[[cs_name]] <- do.call(rbind, lcp_list)
}

##Export
for (cs_name in names(lcp_slope)) {
  lcp_sf <- lcp_slope[[cs_name]]
  
  filename <- paste0("outputs/LCP_", cs_name, ".shp")
  st_write(lcp_sf, filename, append = FALSE)
}

###NPDI validation critical slope
cs_names <- names(lcp_slope)
road_names <- names(roads)

#Empty dataframe to store the results
slope_NPDI_results_df <- data.frame(matrix(NA_real_, nrow = length(cs_names), ncol = length(road_names)))
rownames(slope_NPDI_results_df) <- cs_names
colnames(slope_NPDI_results_df) <- road_names

#loop through LCPs for each CS and calculate NPDI
for (cs_name in cs_names) {
  cat("Processing surface:", cs_name, "\n")
  
  lcp_sf <- lcp_slope[[cs_name]]
  
  for (road_name in road_names) {
    ids <- strsplit(road_name, "_")[[1]]
    from_id <- as.numeric(ids[1])
    to_id   <- as.numeric(ids[2])
    
    #Match the correct LCP by origin and destination IDs
    lcp_sel <- subset(lcp_sf, origin_ID == from_id & destination_ID == to_id)
    
    if (nrow(lcp_sel) == 0) {
      warning("No LCP found for road ", road_name, " in surface ", cs_name)
      next
    }
    
    road_sf <- roads[[road_name]]
    
    #The function returns a dataframe of values
    pdi_result <- PDI_validation_new(lcp_sel, road_sf)
    
    #Extract the NPDI
    slope_NPDI_results_df[cs_name, road_name] <- pdi_result$normalised_pdi
  }
}

write.csv2(slope_NPDI_results_df, "outputs/slope_NPDI.csv")

##Plot critical slope NPDI
slope_NPDI_results_df$conductivity_surface <- rownames(slope_NPDI_results_df)

npdi_slope_long <- slope_NPDI_results_df %>%
  pivot_longer(
    cols = -conductivity_surface,
    names_to = "road",    #road names
    values_to = "NPDI"
  )

ggplot(npdi_slope_long, aes(x = conductivity_surface, y = NPDI, color = road, group = road)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(
    title = "NPDI values (maximum slope cost)",
    x = "Conductivity Surface",
    y = "NPDI",
    color = "Road"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # tilt x labels
  )

###Model LCPs combining topographic variables and critical slope
#Import CSs
sl_05_topo_02 <- terra::rast("data/raster/slope_topo_comb/sl_05_topo_02.tif")
sl_05_topo_05 <- terra::rast("data/raster/slope_topo_comb/sl_05_topo_05.tif")
sl_05_topo_10 <- terra::rast("data/raster/slope_topo_comb/sl_05_topo_10.tif")
sl_10_topo_05 <- terra::rast("data/raster/slope_topo_comb/sl_10_topo_05.tif")
sl_10_topo_02 <- terra::rast("data/raster/slope_topo_comb/sl_10_topo_02.tif")
sl_20_topo_02 <- terra::rast("data/raster/slope_topo_comb/sl_20_topo_02.tif")
sl_20_topo_05 <- terra::rast("data/raster/slope_topo_comb/sl_20_topo_05.tif")
sl_20_topo_10 <- terra::rast("data/raster/slope_topo_comb/sl_20_topo_10.tif")

slope_topo_list <- list(
  sl_05_topo_02 = sl_05_topo_02,
  sl_05_topo_05 = sl_05_topo_05,
  sl_05_topo_10 = sl_05_topo_10,
  sl_10_topo_02 = sl_10_topo_02,
  sl_10_topo_05 = sl_10_topo_05,
  sl_20_topo_02 = sl_20_topo_02,
  sl_20_topo_05 = sl_20_topo_05,
  sl_20_topo_10 = sl_20_topo_10
)

#List to store results
lcp_slope_topo <- list()

#Calculate LCPs for each CS
for (cs_name in names(slope_topo_list)) {
  cat("Processing", cs_name, "...\n")
  
  r <- slope_topo_list[[cs_name]]
  
  #Create conductivity surface
  cs <- create_cs(x = r, neighbours = 16)
  
  #Compute LCPs for each pair of points
  lcp_list <- list()
  
  for (i in seq_len(nrow(pairs))) {
    from <- sites[pairs[i, 1], ]
    to   <- sites[pairs[i, 2], ]
    
    lcp <- create_lcp(cs, origin = from, destination = to)
    
    #Annotate LCP with metadata
    lcp$surface <- cs_name
    lcp$origin_ID <- pairs[i, 1]
    lcp$destination_ID <- pairs[i, 2]
    
    lcp_list[[i]] <- lcp
  }
  
  #Combine LCPs for each surface
  lcp_slope_topo[[cs_name]] <- do.call(rbind, lcp_list)
}

##Export
for (cs_name in names(lcp_slope_topo)) {
  lcp_sf <- lcp_slope_topo[[cs_name]]
  
  filename <- paste0("outputs/LCP_", cs_name, ".shp")
  st_write(lcp_sf, filename, append = FALSE)
}

###NPDI validation topo and critical slope combined
cs_names <- names(lcp_slope_topo)

#Empty dataframe to store the results
slope_topo_NPDI_results_df <- data.frame(matrix(NA_real_, nrow = length(cs_names), ncol = length(road_names)))
rownames(slope_topo_NPDI_results_df) <- cs_names
colnames(slope_topo_NPDI_results_df) <- road_names

#Loop through LCPs for each CS
for (cs_name in cs_names) {
  cat("Processing surface:", cs_name, "\n")
  
  lcp_sf <- lcp_slope_topo[[cs_name]]
  
  for (road_name in road_names) {
    ids <- strsplit(road_name, "_")[[1]]
    from_id <- as.numeric(ids[1])
    to_id   <- as.numeric(ids[2])
    
    #Match the correct LCP by origin and destination IDs
    lcp_sel <- subset(lcp_sf, origin_ID == from_id & destination_ID == to_id)
    
    if (nrow(lcp_sel) == 0) {
      warning("No LCP found for road ", road_name, " in surface ", cs_name)
      next
    }
    
    road_sf <- roads[[road_name]]
    
    #The function returns a dataframe of values
    pdi_result <- PDI_validation_new(lcp_sel, road_sf)
    
    #Extract the NPDI
    slope_topo_NPDI_results_df[cs_name, road_name] <- pdi_result$normalised_pdi
  }
}

write.csv2(slope_topo_NPDI_results_df, "outputs/slope_topo_NPDI.csv")

##Plot topo and slope NPDI
slope_topo_NPDI_results_df$conductivity_surface <- rownames(slope_topo_NPDI_results_df)

npdi_slope_topo_long <- slope_topo_NPDI_results_df %>%
  pivot_longer(
    cols = -conductivity_surface,
    names_to = "road",    #road names
    values_to = "NPDI"
  )

ggplot(npdi_slope_topo_long, aes(x = conductivity_surface, y = NPDI, color = road, group = road)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(
    title = "NPDI values (maximum slope and topo cost)",
    x = "Conductivity Surface",
    y = "NPDI",
    color = "Road"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # tilt x labels
  )

###Modelling LCPs combining topo, critical slope, and slope categories
##Import CSs
sl_100_50_10_topo_02 <- terra::rast("data/raster/slope_cat_topo/sl_100_50_10_topo02.tif")
sl_100_50_33_10_topo_02 <- terra::rast("data/raster/slope_cat_topo/sl_100_50_33_10_topo02.tif")
sl_100_50_20_topo_10 <- terra::rast("data/raster/slope_cat_topo/sl_100_50_20_topo10.tif")
sl_100_50_33_20_topo_10 <- terra::rast("data/raster/slope_cat_topo/sl_100_50_33_20_topo10.tif")

sl_cat_list <- list(
  sl_100_50_10_topo_02 = sl_100_50_10_topo_02,
  sl_100_50_33_10_topo_02 = sl_100_50_33_10_topo_02,
  sl_100_50_20_topo_10 = sl_100_50_20_topo_10,
  sl_100_50_33_20_topo_10 = sl_100_50_33_20_topo_10
)

#List to store results
lcp_slope_cat_topo <- list()

for (cs_name in names(sl_cat_list)) {
  cat("Processing", cs_name, "...\n")
  
  r <- sl_cat_list[[cs_name]]
  
  #Create conductivity surface
  cs <- create_cs(x = r, neighbours = 16)
  
  #Compute LCPs for each pair of points
  lcp_list <- list()
  
  for (i in seq_len(nrow(pairs))) {
    from <- sites[pairs[i, 1], ]
    to   <- sites[pairs[i, 2], ]
    
    lcp <- create_lcp(cs, origin = from, destination = to)
    
    #Annotate LCP with metadata
    lcp$surface <- cs_name
    lcp$origin_ID <- pairs[i, 1]
    lcp$destination_ID <- pairs[i, 2]
    
    lcp_list[[i]] <- lcp
  }
  
  #Combine LCPs for each surface
  lcp_slope_cat_topo[[cs_name]] <- do.call(rbind, lcp_list)
}

##Export
for (cs_name in names(lcp_slope_cat_topo)) {
  lcp_sf <- lcp_slope_cat_topo[[cs_name]]
  
  filename <- paste0("outputs/LCP_", cs_name, ".shp")
  st_write(lcp_sf, filename, append = FALSE)
}

###NPDI validation topo, critical slope, and slope categories
cs_names <- names(lcp_slope_cat_topo)

#Empty dataframe to store the results
slope_cat_topo_NPDI_results_df <- data.frame(matrix(NA_real_, nrow = length(cs_names), ncol = length(road_names)))
rownames(slope_cat_topo_NPDI_results_df) <- cs_names
colnames(slope_cat_topo_NPDI_results_df) <- road_names

for (cs_name in cs_names) {
  cat("Processing surface:", cs_name, "\n")
  
  lcp_sf <- lcp_slope_cat_topo[[cs_name]]
  
  for (road_name in road_names) {
    ids <- strsplit(road_name, "_")[[1]]
    from_id <- as.numeric(ids[1])
    to_id   <- as.numeric(ids[2])
    
    #Match the correct LCP by origin and destination IDs
    lcp_sel <- subset(lcp_sf, origin_ID == from_id & destination_ID == to_id)
    
    if (nrow(lcp_sel) == 0) {
      warning("No LCP found for road ", road_name, " in surface ", cs_name)
      next
    }
    
    road_sf <- roads[[road_name]]
    
    #The function returns a dataframe of values
    pdi_result <- PDI_validation_new(lcp_sel, road_sf)
    
    # Extract the NPDI
    slope_cat_topo_NPDI_results_df[cs_name, road_name] <- pdi_result$normalised_pdi
  }
}

write.csv2(slope_cat_topo_NPDI_results_df, "outputs/slope_cat_topo_NPDI.csv")

##Plot combined CS LCPs NPDI
slope_cat_topo_NPDI_results_df$conductivity_surface <- rownames(slope_cat_topo_NPDI_results_df)

npdi_slope_cat_topo_long <- slope_cat_topo_NPDI_results_df %>%
  pivot_longer(
    cols = -conductivity_surface,
    names_to = "road",    #road names
    values_to = "NPDI"
  )

ggplot(npdi_slope_cat_topo_long, aes(x = conductivity_surface, y = NPDI, color = road, group = road)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(
    title = "NPDI values (maximum slope and topo cost)",
    x = "Conductivity Surface",
    y = "NPDI",
    color = "Road"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # tilt x labels
  )

##Import road Jerusalem-Lydda 2 (Bethoron road)
jr_lyd2 <- st_read("data/vector/jerusalem-lydda2.shp")
jr_lyd2 <- st_zm(jr_lyd2, drop = TRUE, what = "ZM")

##List of roads
roads2 <- list(
  "1_2" = jr_em,
  "1_3" = em_lyd,
  "2_3" = jr_lyd2
)

cs_names <- names(lcp_slope_cat_topo)
road_names <- names(roads2)

###NPDI validation with alternative road Jerusalem-Lydda (Bethoron road)
#Empty dataframe to store the results
slope_cat_topo_NPDI_results_df2 <- data.frame(matrix(NA_real_, nrow = length(cs_names), ncol = length(road_names)))
rownames(slope_cat_topo_NPDI_results_df2) <- cs_names
colnames(slope_cat_topo_NPDI_results_df2) <- road_names

for (cs_name in cs_names) {
  cat("Processing surface:", cs_name, "\n")
  
  lcp_sf <- lcp_slope_cat_topo[[cs_name]]
  
  for (road_name in road_names) {
    ids <- strsplit(road_name, "_")[[1]]
    from_id <- as.numeric(ids[1])
    to_id   <- as.numeric(ids[2])
    
    #Match the correct LCP by origin and destination IDs
    lcp_sel <- subset(lcp_sf, origin_ID == from_id & destination_ID == to_id)
    
    if (nrow(lcp_sel) == 0) {
      warning("No LCP found for road ", road_name, " in surface ", cs_name)
      next
    }
    
    road_sf <- roads2[[road_name]]
    
    #The function returns a dataframe of values
    pdi_result <- PDI_validation_new(lcp_sel, road_sf)
    
    #Extract the NPDI
    slope_cat_topo_NPDI_results_df2[cs_name, road_name] <- pdi_result$normalised_pdi
  }
}

write.csv2(slope_cat_topo_NPDI_results_df2, "outputs/slope_cat_topo_NPDI_bethoron.csv")

##Plot combined CS LCPs NPDI
slope_cat_topo_NPDI_results_df2$conductivity_surface <- rownames(slope_cat_topo_NPDI_results_df2)

npdi_slope_cat_topo_long2 <- slope_cat_topo_NPDI_results_df2 %>%
  pivot_longer(
    cols = -conductivity_surface,
    names_to = "road",    #road names
    values_to = "NPDI"
  )

ggplot(npdi_slope_cat_topo_long2, aes(x = conductivity_surface, y = NPDI, color = road, group = road)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(
    title = "NPDI values (maximum slope and topo cost)",
    x = "Conductivity Surface",
    y = "NPDI",
    color = "Road"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # tilt x labels
  )
