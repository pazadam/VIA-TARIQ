# VIA-TARIQ

**Analysing the long-term change and persistency of the Roman road system in the Levant**

The code stored in this repository is used to undertake research objectives defined in Work Packages 1 and 2 of the VIA-TARIQ project.

The principal research questions that are addressed by this research are:

1.  Is it possible to identify main topographic variables that command location of ancient roads based on the analysis of high-resolution dataset of Roman roads?

2.  Can we use these variables to built a new highly-detailed predictive model of the Roman road network in the Levant?

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### What does this code do?

The code in main.R is titled "Modelling natural corridors of movement in the Levant based on analysis of Roman road data" and it presents two scenarios with several sub-scenarios:

1.  *Modelling natural corridors of movement*

The first scenario focuses on modelling 'natural corridors of movement', i.e. areas where movement is more likely to occur based on a set of given criteria. Approach implemented here is an adaptation of the 'from everywhere to everywhere' (FETE) method (White and Barber 2012, Crabtree et al 2016). While in the original implementation all raster cells are considered as source points, here, due to limitations on computing power and time, only 100 random source points are generated in each simulation. With 50 simulations this results in 5000 source points and 495000 least-cost paths (LCPs) generated in the study region. These are exported as shapefiles and further analysis is done in GIS. This model uses a conductance surface representing topographic variables and their friction values (3 categories of slope, topographic position index - TPI, Vector Ruggedness Measure Local - VRML). The conductance surface (CS) is direction-independent, and therefore it is called 'isotropic' throughout the code.

2.  *Modelling FETE LCPs in the Southern Levant and comparing various cost functions*

The second scenario focuses on Southern Levant, essentially asking question if the results of the first scenario can be improved when looking at smaller-scale and employing higher spatial resolution conductance surface (see *Data* below). In the first sub-scenario FETE LCPs are computed using the isotropic CS for a) regular grid of 110 points (spaced \~30 km apart), and b) 43 selected Roman sites. In the first instance it results in 11990 LCPs, in the second in 1806 LCPs. In the second sub-scenario FETE LCPs are computed for the same two sets of points using four different slope-based functions, two time-optimizing: Tobler (1993) and Naismith (1892), and two energy-optimizing: Herzog (2013) and Llobera-Sluckin (2007). In the next step, isotropic FETE LCPs computed for regular grid of points are compared to
