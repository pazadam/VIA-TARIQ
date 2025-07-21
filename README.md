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

The code stored in this repository is used to undertake research objectives defined in Work Packages 1 and 2 of the VIA-TARIQ project, and accompanies article —-.

The principal research questions that are addressed by these WPs are:

1.  Is it possible to identify main topographic variables that command location of ancient roads based on the analysis of high-resolution dataset of Roman roads?

2.  Can we use these variables to built a new highly-detailed predictive model of the Roman road network in the Levant?

The code in this repository is addressing several aspects of this research through least-cost path (LCP) and network modelling. While the first part of the research – identifying topographic constrains of the ancient roads – was done in GIS, its results are reused in this analysis. The further issues explored here are:

1.  Since we identify topographic variables constraining the locations of ancient (Roman roads), it is possible to use these variable to model movement in the landscape. These variables are then used to model 'natural corridors of movement' i.e., places in the landscapes where movement is naturally channeled to. The variables considered are: 3 categories of slope, Topographic Position Index (TPI), and Vector Ruggedness Measure Local (VRML). The model is isotropic (direction independent) and so is called 'isotropic model' throughout the text.

2.  Modeled 'natural corridors of movement' are then compared to the known network of Roman roads. In this step, an influence of topographic variables on location and shape of the Roman road network is evaluated. If the topographic variables are the main driving force influencing the shape of the Roman road network, then the Roman roads should be roughly co-terminous with the 'natural corridors of movement'. Any deviations then could be explained by other factors not considered (land use, distribution of water sources, settlement patterns, other cultural variables, etc.).

3.  Finally, LCPs calculated between Roman sites using various cost functions (isotropic model and four selected slope-based functions) are compared to 60 selected Roman roads. The performance of the cost functions in predicting the course of Roman roads is evaluated and compared. This is done in order to explore and evaluate the differences in modeled LCPs and how the isotropic model based on topographic variables, besides slope, performs compared to slope-based functions. In theory, the isotropic model, which is directly derived from topographic variables identified on ancient Roman roads should perform better than the rest.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Description

The code in ***main.R*** is titled "**Modelling natural corridors of movement in the Levant based on analysis of Roman road data**" and it presents two scenarios with several sub-scenarios:

1.  *Modelling natural corridors of movement*

The first scenario focuses on modelling 'natural corridors of movement', i.e. areas where movement is more likely to occur based on a set of given criteria. Approach implemented here is an adaptation of the 'from everywhere to everywhere' (FETE) method (White and Barber 2012, Crabtree et al 2021). While in the original implementation all raster cells are considered as source points, here, due to limitations on computing power and time, only 100 random source points are generated in each simulation. With 50 simulations this results in 5,000 source points and 495,000 least-cost paths (LCPs) generated in the study region. This model uses a conductance surface representing topographic variables and their friction values (3 categories of slope, topographic position index - TPI, and Vector Ruggedness Measure Local - VRML). The conductance surface (CS) is direction-independent, and therefore it is called 'isotropic' throughout the code. The LCPs are exported as shapefiles and further analysis is done in GIS to explore their relationship with known Roman roads.

2.  *Modelling FETE LCPs in the Southern Levant and comparing various cost functions*

The second scenario focuses on the southern Levant, essentially asking question if the results of the first scenario can be improved when looking at smaller-scale and employing higher spatial resolution conductance surface (see *Data* below). In the first sub-scenario FETE LCPs are computed using the isotropic CS using the same methodology as in the first case (100 random points, 50 runs). The second sub-scenario evaluates the predictive power of the isotropic function and four different slope-based functions, two time-optimizing: Tobler (1993) and Naismith (1892), and two energy-optimizing: Herzog (2013) and Llobera-Sluckin (2007). LCPs are calculated between selected Roman sites using all cost functions and these are in turn compared with 60 selected Roman roads (2,808.8 km), using NPDI (normalized path deviation index) method.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Data

The ***data*** folder contains the following input data for the code:

-   **b_box.shp**

Bounding box for the generation of the random points in the scenario 1. It outlines the landmass of the region of interest (i.e., excluding the sea), roughly between Taurus Mts. and Sinai and the Euphrates/Syrian Desert and the Mediterranean Sea (ca. 612,810 km^2^).

-   **levant_conductance_250.tif**

Raster representing conductivity values in the landscape with resolution of 250 m. It is based on 30 m resolution slope (4 categories), TPI, and VRML rasters, which are in themselves based on the FABDEM (Hawker et al 2022, <font color="red">see Zenodo repository for the full dataset and description of the source raster layers)</font>. These raster layers were mosaiced into one with only the lowest value in given cell location retained. The original 30 m resolution conductivity raster was resampled to 250 m resolution using 'Majority' function in 'Resample' tool in ArcGIS Pro v3 (in order to limit computational demands). The values in the raster represent conductivity of different terrain types (low values represent low conductivity):

|  |  |
|----|----|
| **Terrain type** | **Conductivity values** |
| Slope \<5° | 100 |
| Slope 5-10° | 50 |
| Slope 10-20° | 33 |
| Slope \>20° | 10 |
| VRML \>0.002332516 | 5 |
| TPI (\>-80.709 \<91.175) | 2 |
| Marshlands |  |
| (Amuq, al-Ghab, Jabboul, ar-Ruj, Biqqa, Hule) | 2 |
| Lakes |  |
| (Gavur Gölü, Amuq, ar-Ruj, Homs Lake, Hule, Dead Sea) | 0 |

-   **south_case_roads.shp**

Layer of 60 selected Roman roads in the Southern Levant used for comparison with calculated LCPs in the scenario 2. The roads are coming from the *Itiner-e* dataset (Brughmans et al 2024).

-   **south_conductance_75.tif**

Raster representing conductivity values in the landscape with resolution of 75 m used in the scenario 2. It was created using same procedure as *levant_conductance_250.tif*, only it was resampled to 75 m resolution.

-   **south_dem_70.tif**

Digital Elevation Model (DEM) used for creation of slope-based conductance surfaces in scenario 2. It is based on the 30 m resolution FABDEM, created following the same procedure and containing same conductivity values as the *levant_conductance_250.tif* (see above) that was resampled to 70 m resolution in order to limit computational demands. It was resampled using 'Bilinear Resampling' method in 'Resample' tool in ArcGIS Pro v3.

-   **south_sites.shp**

Layer of 43 selected Roman sites used for calculating LCPs in the scenario 2. The sites were selected according to several criteria: a) They represent accepted urban sites c. 200 CE (Hanson 2016), b) Mints according to *Roman Provincial Coinage* (<https://rpc.ashmus.ox.ac.uk>), c) other urban sites, road-stations, and forts added for areal coverage (Mampsis, Negla, Nessana, Neue, Oboda).

All data is in projected coordinated system **EPSG:3395 (World Mercator)**.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Output

Due to storage limitations, only two output files are included in the repository (folder ***output***), as the FETE LCPs have total size of several GB. For the full dataset see Zenodo repository.

-   **n_pdi_comparison.tiff**

A plot showing normalised PDI values comparing isotropic model with each of the four selected slope-based algorithms. X sign shows mean NPDI value.

-   **n_pdi_roman_roads.tiff**

A plot showing normalised PDI values comparing 60 selected Roman roads with the isotropic model and four selected slope-based algorithms. X sign shows mean NPDI value.

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
