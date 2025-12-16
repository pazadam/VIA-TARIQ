# VIA-TARIQ

**Analysing the long-term change and persistency of the Roman road system in the Levant**

-   [Introduction](https://github.com/pazadam/VIA-TARIQ#introduction)
-   [Description](https://github.com/pazadam/VIA-TARIQ#description)
-   [Data](https://github.com/pazadam/VIA-TARIQ#data)
-   [Output](https://github.com/pazadam/VIA-TARIQ#output)
-   [Note on the usage](https://github.com/pazadam/VIA-TARIQ#note-on-the-usage)
-   [Dependencies](https://github.com/pazadam/VIA-TARIQ#dependencies)
-   [Bibliography](https://github.com/pazadam/VIA-TARIQ#bibliography)

### Introduction

The code stored in this repository is used to undertake research objectives defined in Work Packages 1 of the VIA-TARIQ project, and accompanies article '*Using Roman road data to evaluate limits of topography on road location*'.

The principal research questions that are addressed by the WP 1 are:

1.  Is it possible to identify main topographic variables that command location of ancient roads based on the analysis of high-resolution dataset of Roman roads?

2.  What was the influence of these topographic constraints on the location of the Roman roads in the Near East?

The code in this repository is addressing several aspects of this research through least-cost path (LCP) modelling. While the first part of the research – identifying topographic constrains of the ancient roads – was done in GIS, its results are reused in this analysis. The further issues explored here are:

1.  Since we identify topographic variables constraining the locations of ancient (Roman roads), it is possible to use these variable to model movement in the landscape. These variables are then used to model 'natural corridors of movement' i.e., places in the landscapes where movement is naturally channeled to. The variables considered are: 3 categories of slope, Topographic Position Index (TPI), and Vector Ruggedness Measure Local (VRML). The model is isotropic (direction independent) and so is called 'isotropic model' throughout the text.

2.  Crucial step in modeling the movement corridors using the selected variables is assigning conductivity values to them (*leastcostpath* package used throughout this code uses conductance surface rather than friction surface, conductance is understood as inverse of friction). A test where various conductivity values for topographic variables, critical slope and slope categories were evaluated was designed on three roads in the Jerusalem region. The conductance surface that showed the best-fit between modelled LCPs and known Roman roads were then used to model the 'natural corridors of movement'. The best-fit is evaluated using normalized path deviation index (NPDI)

3.  Modeled 'natural corridors of movement' are then compared to the known network of Roman roads. In this step, an influence of topographic variables on location and shape of the Roman road network is evaluated. If the topographic variables are the main driving force influencing the shape of the Roman road network, then the Roman roads should be roughly co-terminous with the 'natural corridors of movement'. Any deviations then could be explained by other factors not considered (land use, distribution of water sources, settlement patterns, other cultural variables, etc.).

4.  Finally, the performance of the proposed isotropic model(s) is compared to selected slope-based functions (Tobler, Naismith, Herzog, Llobera-Sluckin). Natural corridors of movement are calculated using these four functions in order to evaluate whether the isotropic model is better in explaining locations of Roman roads than slope-based anisotropic models.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Description

The code in ***main.R*** is titled "**Modelling natural corridors of movement in the Levant based on analysis of Roman road data**" and it presents two scenarios with several sub-scenarios:

1.  *Modelling natural corridors of movement in the Southern Levant using isotropic model(s)*

The first scenario focuses on modelling 'natural corridors of movement', i.e. areas where movement is more likely to occur based on a set of given criteria. Approach implemented here is an adaptation of the 'from everywhere to everywhere' (FETE) method (White and Barber 2012, Crabtree et al 2021). While in the original implementation all raster cells are considered as source points, here, due to limitations on computing power and time, only 100 random source points are generated in each simulation. With 50 simulations this results in 5,000 source points and 495,000 least-cost paths (LCPs) generated in the case study region. This model uses a conductance surface representing topographic variables and their friction values (3 categories of slope, topographic position index - TPI, and Vector Ruggedness Measure Local - VRML). The conductance surface (CS) is direction-independent, and therefore it is called 'isotropic' throughout the code. The LCPs are exported as shapefiles and further analysis is done in GIS to explore their relationship with known Roman roads. SInce the test case of assigning the conductivitiy values showed that two different models performed very similarly (model A, model B), the corridors are calculated for each model separately and then evaluated.

2.  *Modelling natural corridors of movement in the Southern Levant using slope-based functions*

The second scenario focuses on modelling the natural corridors of movemnet using different slope-based functions, which are then compared with the results obtained in the scenario 1. Each sub-scenario represents one fo the four selected algorithms, two time-optimizing: Tobler (1993) and Naismith (1892), and two energy-optimizing: Herzog (2013) and Llobera-Sluckin (2007). FETE LCPs are calculated using slightl simplified methodology compared to the scenario 1, with only 50 random points and 10 simulation runs, resulting in 24,500 LCPs for each evaluated function.

The code in ***test_case_conductivity_values.R*** is titled: "**Test case: assigning the conductivity values**". As the name implies, its focus is on testing various conductivity values for topographic constrains, critical slope and slope categories and their combinations. It shows how the conductivity values used in the conductance surfaces for the isotropic models (Model A and B) were derived empirically from comparing modeled LCPs with the selected known Roman roads in the Jerusalem area.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Data

The ***data*** folder contains the input data for the code in *vector* and *raster* sub-folders:

***vector***:

-   **b_box_south.shp**

Bounding box (polygon) for the generation of the random points in the scenario 1. It outlines the landmass of the region of interest (i.e., excluding the sea and lakes), roughly south of the line Tyre-Damascus to the Red Sea (ca. 62,323 km^2^).

-   **emmaus-lydda.shp**

One of the known Roman roads (line) used in the test assigning the conductivity values to the topographic variables and critical slope. Used in NPDI calculations with the modeled LCPs.

-   **jerusalem-emmaus.shp**

One of the known Roman roads (line) used in the test assigning the conductivity values to the topographic variables and critical slope. Used in NPDI calculations with the modeled LCPs.

-   **jerusalem-lydda.shp**

One of the known Roman roads (line) used in the test assigning the conductivity values to the topographic variables and critical slope. Used in NPDI calculations with the modeled LCPs.

-   **jerusalem-lydda2.shp**

One of the known Roman roads (line) used in the test assigning the conductivity values to the topographic variables and critical slope. Alternative to the previous road, so-called Bethoron road. Used in NPDI calculations with the modeled LCPs.

-   **sites_evaluation.shp**

Point layer with the three sites (Jerusalem, Emmaus, Lydda) used in the test assigning the conductivity values to the topographic variables and critical slope. Used as source and destination points for LCP modelling.

***raster:***

The folder is divide into several sub-folders:

**vrml_tpi_cond**: contains combined TPI and VRML conductance surfaces. Numbers after underscore \_ indicate the conductivity value.

**slope_cond**: contains conductivity surfaces for critical slope and slope categories. Numbers after underscore \_ indicate the conductivity value.

**slope_topo_comb**: contains conductance surface for combined topographic variables and critical slope. Numbers after underscore \_ indicate the conductivity value.

**slope_cat_topo:** contains conductance surface for combined topographic variables, critical slope, and slope categories. Numbers after underscore \_ indicate the conductivity value.

-   **south_conductance_75_sl10_t02.tif**

Raster representing conductivity values in the landscape with resolution of 75 m. This is Model A - more sensitive to topography and slope categories. It is based on 30 m resolution slope (4 categories), TPI, and VRML rasters, which are in themselves based on the FABDEM (Hawker et al 2022, see Zenodo repository for the source raster layers [https://doi.org/](https://doi.org/10.5281/zenodo.16273367){.uri}[10.5281/zenodo.17953712](https://doi.org/10.5281/zenodo.17953712){.uri}). These raster layers were mosaiced into one with only the lowest value in given cell location retained. The original 30 m resolution conductivity raster was resampled to 75 m resolution using 'Majority' function in 'Resample' tool in ArcGIS Pro v3 (in order to limit computational demands). The values in the raster represent conductivity of different terrain types (low values represent low conductivity):

|  |  |
|----------------------------------------------|--------------------------|
| **Terrain type** | **Conductivity values** |
| Slope \<5° | 100 |
| Slope 5-10° | 50 |
| Slope 10-20° | 33 |
| Slope \>20° | 10 |
| VRML \>0.002332516 | 2 |
| TPI (\>-80.709 \<91.175) | 2 |
| Marshlands |  |
| (Amuq, al-Ghab, Jabboul, ar-Ruj, Biqqa, Hule) | 2 |
| Lakes |  |
| (Gavur Gölü, Amuq, ar-Ruj, Homs Lake, Hule, Dead Sea) | 0 |

-   **south_conductance_75_sl20_t10.tif**

Raster representing conductivity values in the landscape with resolution of 75 m. This is Model B - less sensitive to topography and slope categories. It was created using same input data and methods as the conductance surface for Model A. The values in the raster represent conductivity of different terrain types (low values represent low conductivity):

|  |  |
|----------------------------------------------|--------------------------|
| **Terrain type** | **Conductivity values** |
| Slope \<10° | 100 |
| Slope 10-20° | 50 |
| Slope \>20° | 20 |
| VRML \>0.002332516 | 10 |
| TPI (\>-80.709 \<91.175) | 10 |
| Marshlands |  |
| (Amuq, al-Ghab, Jabboul, ar-Ruj, Biqqa, Hule) | 2 |
| Lakes |  |
| (Gavur Gölü, Amuq, ar-Ruj, Homs Lake, Hule, Dead Sea) | 0 |

-   **south_dem_75.tif**

Digital Elevation Model (DEM) used for creation of slope-based conductance surfaces in scenario 2. It is based on the 30 m resolution FABDEM, that was resampled to 75 m resolution in order to limit computational demands. It was resampled using 'Bilinear Resampling' method in 'Resample' tool in ArcGIS Pro v3.

All data is in projected coordinated system **EPSG:3395 (World Mercator)**.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Outputs

Due to storage limitations only results of the test assigning the conductivity values are included in the repository (folder ***outputs***), as the FETE LCPs have total size of several GB. For more comprehensive overview of the outputs see Zenodo repository (<https://doi.org/10.5281/zenodo.17953712>).

-   **LCP\_ .shp**

Files starting with LCP\_ are LCPs generated using different conductance surfaces (indicated after the underscore). It is a polyline vector file with three lines (representing 3 pairs of roads) for each conductance surface

-   **npdi\_ .tiff**

FIles starting with npdi\_ are plots showing normalised PDI (NPDI) values comparing modeled LCPs and the three Roman roads.

-   **.csv**

.csv files contain calculated NPDI values for each set of conductance surface. They are collated into table 3 of the article.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### **Note on the usage**

Since source points in the scenario 1 are generated randomly in each simulation run, the resulting LCPs will differ every time the script is ran. The assumptions is that the number of calculated LCPs is high enough to reveal statistically more probable places that channel movement in the landscape (natural corridors of movement) with only minor deviations. The full evaluation and analysis of the material is provided in the article that refers to this repository, and full dataset is published at Zenodo repository.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Dependencies

The code depends on following R packages:

-   [sf](https://cran.r-project.org/web/packages/sf/index.html)

-   [terra](https://cran.r-project.org/web/packages/terra/index.html)

-   [leastcostpath](https://cran.r-project.org/web/packages/leastcostpath/index.html)

-   [dplyr](https://cran.r-project.org/web/packages/dplyr/index.html)

-   [tidyr](https://cran.r-project.org/web/packages/tidyr/index.html)

-   [foreach](https://cran.r-project.org/web/packages/foreach/index.html)

-   [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Bibliography

Crabtree, S. et al. 2016. Landscape rules predict optimal superhighways for the first peopling of Sahul. *Nature Human Behaviour* 5, 1303-1313. DOI: [10.1038/s41562-021-01106-8](https://doi.org/10.1038/s41562-021-01106-8)

Hanson, J.W. 2016. *Cities Database (OXREP database)*. Version 1.0. Accessed 1/12/2024: <http://oxrep.classics.ox.ac.uk/databases/cities/>. DOI: <https://doi.org/10.5287/bodleian:eqapevAn8>

Hawker, L. et al. 2022. A 30 m global map of elevation with forests and buildings removed. *Environmental Research Letters* 17. DOI: [10.1088/1748-9326/ac4d4f](https://doi.org/10.1088/1748-9326/ac4d4f)

Herzog, I. 2013. "The Potential and Limits of Optimal Path Analysis," in Bevan, A. and M. Lake (eds.) *Computational Approaches to Archaeological Spaces*. Institute of Archaeology, University College London. London, 179-211.

Llobera, M. and Sluckin, T.J. 2007. "Zigzagging: Theoretical Insights on Climbing Strategies," *Journal of Theoretical Biology* 249, 206-217.

Naismith, W. 1892. Excursions: Cruach Ardran, Stobinian, and Ben More, *Scottish Mountaineering Club Journal* 2, 136.

Tobler, W. 1993. Three Presentations on Geographical Analysis and Modelling. *Technical Report* 93-1. Santa Barbara, CA.

White, D.A. and Barber, S.B. 2012. Geospatial modeling of pedestrian transportation networks: a case study from precolumbian Oaxaca, Mexico. *Journal of Archaeological Science* 39:8, 2684-2696. DOI: [10.1016/j.jas.2012.04.017](https://doi.org/10.1016/j.jas.2012.04.017)

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Shield: [![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by/4.0/)

This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

[![CC BY 4.0](https://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)
