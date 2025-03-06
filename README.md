# VIA-TARIQ

**Analysing the long-term change and persistency of the Roman road system in the Levant**

The code stored in this repository is used to undertake research objectives defined in Work Packages 1 and 2 of the VIA-TARIQ project.

The principal research questions that are addressed by this research are:

1.  Is it possible to identify main topographic variables that command location of ancient roads based on the analysis of high-resolution dataset of Roman roads?

2.  Can we use these variables to built a new highly-detailed predictive model of the Roman road network in the Levant?

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### What does this code do?

The code in ***main.R*** is titled "**Modelling natural corridors of movement in the Levant based on analysis of Roman road data**" and it presents two scenarios with several sub-scenarios:

1.  *Modelling natural corridors of movement*

The first scenario focuses on modelling 'natural corridors of movement', i.e. areas where movement is more likely to occur based on a set of given criteria. Approach implemented here is an adaptation of the 'from everywhere to everywhere' (FETE) method (White and Barber 2012, Crabtree et al 2016). While in the original implementation all raster cells are considered as source points, here, due to limitations on computing power and time, only 100 random source points are generated in each simulation. With 50 simulations this results in 5,000 source points and 495,000 least-cost paths (LCPs) generated in the study region. This model uses a conductance surface representing topographic variables and their friction values (3 categories of slope, topographic position index - TPI, Vector Ruggedness Measure Local - VRML). The conductance surface (CS) is direction-independent, and therefore it is called 'isotropic' throughout the code. The LCPs are exported as shapefiles and further analysis is done in GIS to explore their relationship with known Roman roads.

2.  *Modelling FETE LCPs in the Southern Levant and comparing various cost functions*

The second scenario focuses on Southern Levant, essentially asking question if the results of the first scenario can be improved when looking at smaller-scale and employing higher spatial resolution conductance surface (see *Data* below). In the first sub-scenario FETE LCPs are computed using the isotropic CS for a) regular grid of 110 points (spaced \~30 km apart), and b) 43 selected Roman sites. In the first instance it results in 11,990 LCPs, in the second in 1,806 LCPs. In the second sub-scenario FETE LCPs are computed for the same two sets of points using four different slope-based functions, two time-optimizing: Tobler (1993) and Naismith (1892), and two energy-optimizing: Herzog (2013) and Llobera-Sluckin (2007). In the next step, isotropic FETE LCPs computed for regular grid of points are compared to FETE LCPs obtained from slope-based functions, using normalised path deviation index (NPDI). This is done in order to evaluate performance of the isotropic model in comparison to the slope-based function. Finally, FETE LCPs calculated between selected Roman sites using all cost functions are compared with 60 selected Roman roads (2,808.8 km), using NPDI method to evaluate their performance in predicting location of Roman roads.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Data

The '*data*' folder contains the following input data for the code:

-   **b_box.shp**

Bounding box for the generation of the random points in the scenario 1. It outlines the landmass of the region of interest (i.e., excluding the sea), roughly between Taurus Mts. and Sinai and the Euphrates/Syrian Desert and the Mediterranean Sea (ca. 612,810 km^2^).

-   **levant_conductance_250.tif**

Raster representing conductivity values in the landscape with resolution of 250 m. It is based on 30 m resolution slope (4 categories), TPI, and VRML rasters, which are in themselves based on the FABDEM (Hawker et al 2022, <font color="red">see Zenodo for the full description of the source raster layers)</font>. These raster layers were mosaiced into one with only the lowest value in given cell location retained. The original 30 m resolution conductivity raster was resampled to 250 m resolution using 'Majority' function in 'Resample' tool in ArcGIS Pro v3 (in order to limit computational demands). The values in the raster represent conductivity of different terrain types (low values represent low conductivity):

|  |  |
|----------------------|-------------------|
| **Terrain type** | **Conductivity values** |
| Slope \<5° | 100 |
| Slope 5-10° | 50 |
| Slope 10-20° | 33 |
| Slope \>20° | 10 |
| VRML \>0.002332516 | 5 |
| TPI (\>-80.709 \<91.175) | 2 |
| Marshlands
(Amuq, al-Ghab, Jabboul, ar-Ruj, Biqqa, Hule) | 2 |
| Lakes
(Gavur Gölü, Amuq, ar-Ruj, Homs Lake, Hule, Dead Sea) | 0 |

-    **south_case_roads.shp**

Layer of 60 selected Roman roads in the Southern Levant used for comparison with calculated LCPs in the scenario 2. THe roads are coming from the *Itiner-e* dataset (Brughmans et al 2024).

-   **south_conductance_70.tif**

Raster representing conductivity values in the landscape with resolution of 70 m used in the scenario 2. It was created using same procedure as *levant_conductance_250.tif*, only it was resampled to 70 m resolution.

-   **south_dem_70.tif**

Digital Elevation Model (DEM) used for creation of slope-based conductance surfaces in scenario 2. It is based on the 30 m resolution FABDEM (see above) that was resampled to 70 m resolution in order to limit computational demands. It was resampled using 'Bilinear Resampling' method in 'Resample' tool in ArcGIS Pro v3.

-   **south_sites.shp**

Layer of 43 selected Roman sites used for calculating LCPs in the scenario 2. The sites were selected according to several criteria: a) They represent accepted urban sites c. 200 CE (Hanson 2016), b) Mints according to *Roman Provincial Coinage* (<https://rpc.ashmus.ox.ac.uk>), c) other urban sites, road-stations, and forts added for areal coverage (Mampsis, Negla, Nessana, Neue, Oboda).

-   **south_source_points.shp**

Layer of of source points used to calculate FETE LCPs in scenario 2. They are arranged in a regular orthogonal grid with a spacing of 30 km over continuouss landmass, except for large water bodies.

All data is in projected coordinated system **EPSG:3395 (World Mercator)**.

Shield: [![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by/4.0/)

This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

[![CC BY 4.0](https://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)
