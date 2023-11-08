geoPlotMap2 <- function(params, 
                        data=NULL, 
                        source=NULL, 
                        surface=NULL, 
                        surfaceCols=NULL, 
                        zoom=NULL, 
                        latLimits=NULL, 
                        lonLimits=NULL, 
                        mapSource="google", 
                        mapType="hybrid", 
                        opacity=0.1, 
                        plotContours=TRUE, 
                        breakPercent=seq(0,100,l=11), 
                        contourCol= "grey50", 
                        smoothScale=TRUE, 
                        crimeCex=1.5, 
                        crimeCol='red', 
                        crimeBorderCol='white', 
                        crimeBorderWidth=0.5, 
                        sourceCex=1.5, 
                        sourceCol='blue', 
                        gpLegend=TRUE,
                        palette = "RdYlBu") {
  
  library(leaflet)
  library(sf)
  library(tidyverse)
  library(leaflet.extras)
  
  # check that inputs make sense
  geoParamsCheck(params)
  if (!is.null(data)) { geoDataCheck(data) }
  
  # set defaults
  if (is.null(surfaceCols)) { surfaceCols <- viridis::plasma(100) }
  if (is.null(latLimits)) { latLimits <- params$output$latitude_minMax }
  if (is.null(lonLimits)) { lonLimits <- params$output$longitude_minMax }
  
  # if zoom=="auto" then set zoom level based on params
  # if (is.null(zoom)) { 
  #   zoom <- getZoom(params$output$longitude_minMax, params$output$latitude_minMax)
  #   cat(paste0("using zoom=", zoom, "\n"))
  # }
  
  # make zoom level appropriate to map source
  # if (mapSource=="stamen") { zoom <- min(zoom,18) }
  
  # download map
  # cat("downloading map\n")
  # loc <- c(mean(params$output$longitude_minMax), mean(params$output$latitude_minMax))
  # rawMap <- get_map(location=loc, zoom=zoom, source=mapSource, maptype=mapType)
  
  # get attributes from rawMap (bounding box)
  # att <- unlist(attributes(rawMap)$bb)
  # latVec <- seq(att[3], att[1], l=nrow(rawMap))
  # lonVec <- seq(att[2], att[4], l=ncol(rawMap))
  # df_rawMap <- data.frame(lat=rep(latVec, each=ncol(rawMap)), lon=rep(lonVec, times=nrow(rawMap)))
  # 
  # # bind with colours from rawMap
  # df_rawMap <- cbind(df_rawMap, col=as.vector(rawMap))
  # 
  # # create ggplot object
  # belgium <- rworldmap::getMap(resolution = "low") %>% 
  #   st_as_sf() %>% 
  #   mutate(ADMIN = as.character(ADMIN)) %>% 
  #   filter(ADMIN == "United Kingdom")
  # 
  # myMap <- ggplot() + geom_sf(data = belgium, aes())
  # myMap <- myMap + coord_cartesian(xlim=lonLimits, ylim=latLimits, expand=FALSE)
  
  # overlay geoprofile
  if (!is.null(surface)) {
    
    # create colour palette
    geoCols <- colorRampPalette(rev(surfaceCols))
    nbcol <- length(breakPercent)-1
    
    # extract plotting ranges and determine midpoints of cells
    longitude_minMax  <- params$output$longitude_minMax
    latitude_minMax  <- params$output$latitude_minMax
    longitude_cells  <- params$output$longitude_cells
    latitude_cells  <- params$output$latitude_cells
    longitude_cellSize <- diff(longitude_minMax)/longitude_cells
    latitude_cellSize <- diff(latitude_minMax)/latitude_cells
    longitude_midpoints <- longitude_minMax[1] - longitude_cellSize/2 + (1:longitude_cells)* longitude_cellSize
    latitude_midpoints <- latitude_minMax[1] - latitude_cellSize/2 + (1:latitude_cells)* latitude_cellSize
    
    # create data frame of x,y,z values and labels for contour level
    df <- expand.grid(x=longitude_midpoints, y=latitude_midpoints)
    df$z <- as.vector(t(surface))
    labs <- paste(round(breakPercent,1)[-length(breakPercent)],"-",round(breakPercent,1)[-1],"%",sep='')
    df$cut <- cut(df$z, breakPercent, labels=labs)
    df$col <- rev(geoCols(nbcol))[df$cut]
    
    # remove all entries outside of breakPercent range
    df_noNA <- df[!is.na(df$cut),]
    
    df_noNA_sf <- df_noNA %>% 
      st_as_sf(coords = c("x", "y")) %>% 
      mutate(z = as.numeric(z)) %>% 
      filter(z < 95)
    
    bbox <- st_bbox(df_noNA_sf)
    
    source <- as.data.frame(s) %>% 
      st_as_sf(coords=c("longitude", "latitude"))
    
    data <- as.data.frame(d) %>% 
      st_as_sf(coords=c("longitude", "latitude"))
    
    # # convert current map into borderless background image
    # background <- myMap + theme_nothing()
    # myMap <- ggplot() + annotation_custom(grob=ggplotGrob(background), xmin=lonLimits[1], xmax=lonLimits[2], ymin=latLimits[1], ymax=latLimits[2])
    
    pal <- colorBin(palette = palette,
                    domain = df_noNA_sf$z,
                    bins = 7)
    
    myMap <- leaflet() %>% 
      addCircles(data = df_noNA_sf,
                 color = ~pal(z),
                 fill = ~pal(z),
                 opacity = opacity,
                 fillOpacity = opacity,
                 weight = 1,
                 stroke = FALSE
      ) %>% 
      addCircles(data = source,
                 color = "white",
                 opacity = 1,
                 weight = 5) %>% 
      addCircles(data = data,
                 fill = "red",
                 color = "black",
                 opacity = 1,
                 weight = 2)
    
    # add surface and colour scale
    #   if (smoothScale) {
    #     
    #     
    #     myMap <- myMap + geom_raster(aes_string(x='x', y='y', fill='z'), alpha=opacity, data=df_noNA)
    #     myMap <- myMap + scale_fill_gradientn(name="Hitscore\npercentage", colours=rev(surfaceCols))
    #   } else {
    #     myMap <- myMap + geom_raster(aes_string(x='x', y='y', fill='col'), alpha=opacity, data=df_noNA)
    #     myMap <- myMap + scale_fill_manual(name="Hitscore\npercentage", labels=labs, values=geoCols(nbcol))
    #   }
    #   if (!gpLegend) {
    #     myMap <- myMap + theme(legend.position="none")
    #   }
    #   
    #   # add plotting limits
    #   myMap <- myMap + coord_cartesian(xlim=lonLimits, ylim=latLimits, expand=FALSE)
    #   
    #   # add contours
    #   if (plotContours) {
    #     myMap <- myMap + stat_contour(aes_string(x='x', y='y', z='z'), colour=contourCol, breaks=breakPercent, size=0.3, alpha=opacity, data=df)
    #   }
    # }
    # 
    # # overlay data points
    # if (!is.null(data)) {
    #   df_data <- data.frame(longitude=data$longitude, latitude=data$latitude)
    #   myMap <- myMap + geom_point(aes_string(x='longitude', y='latitude'), data=df_data, pch=21, stroke=crimeBorderWidth, cex=crimeCex, fill=crimeCol, col=crimeBorderCol)
    # }
    # 
    # # overlay source points
    # if (!is.null(source)) {
    #   df_source <- data.frame(longitude=source$longitude, latitude=source$latitude)
    #   myMap <- myMap + geom_point(aes_string(x='longitude', y='latitude'), data=df_source, pch=15, cex=sourceCex, col=sourceCol, fill=NA)
  }
  # 
  # # force correct aspect ratio
  # centre_lat <- mean(params$output$latitude_minMax)
  # centre_lon <- mean(params$output$longitude_minMax)
  # scale_lat <- latlon_to_bearing(centre_lat, centre_lon, centre_lat + 0.1, centre_lon)$gc_dist
  # scale_lon <- latlon_to_bearing(centre_lat, centre_lon, centre_lat, centre_lon + 0.1)$gc_dist
  # asp <- diff(latLimits)*scale_lat / (diff(lonLimits)*scale_lon)
  # myMap <- myMap +  theme(aspect.ratio=asp)
  # 
  # # add labels
  # myMap <- myMap +  labs(x="longitude", y="latitude")
  # 
  # plot map
  return(myMap)
}
