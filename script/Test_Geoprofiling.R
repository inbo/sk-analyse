# setwd("G:/Mijn Drive/Projecten/SK/4_SK_PopGen/GeoProfiling")

# Geoprofiling using Dirichlet Process Mixture (DPM) framework using Rgeoprofile
# https://github.com/bobverity/Rgeoprofile

# occ.df <- read.csv("BF_Occurrences20231103.csv", header=T, sep=';')

install.packages("Rtools")
library(devtools)

# install_github("bobverity/RgeoProfile")
library(RgeoProfile)
library(ggmap)
??RgeoProfile




# full example of Rgeoprofile 2.1.0 workflow, illustrating all functions
# for details, see help for individual functions

#------------------------------------------------------------------
# data and settings
#------------------------------------------------------------------
# example data
d <- LondonExample_crimes
s <- LondonExample_sources

# convert d and s to correct format for geoParams()
# (note that in this case the example data are already in the correct
# format; these steps are only relevant if for example d and s are 
# imported as two-column matrices. They are included here for
# completeness)
d <- geoData(d$longitude, d$latitude)
s <- geoDataSource(s$longitude, s$latitude)




# set model and MCMC parameters
p = geoParams(data = d, sigma_mean = 1, sigma_squared_shape = 2, chains = 5, 
              burnin = 1e3, samples = 1e4)


# run MCMC
m = geoMCMC(data = d, params = p)





#------------------------------------------------------------------
# output
#------------------------------------------------------------------
# plot prior and posterior of sigma
geoPlotSigma(params = p, mcmc = m)


# plot profile on map

install_github("dkahle/ggmap")
library(ggmap)
register_google(key ="") #insert API-key


mapGP <- geoPlotMap(params = p, data = d, source = s, surface = m$geoProfile)
mapGP