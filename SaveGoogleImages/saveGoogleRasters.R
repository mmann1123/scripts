library(ggmap)
library(raster)
library(maptools)
library(rgdal)

image_footprints <- readOGR(dsn = "/Users/wabarr/Desktop/KoobiForaFieldSchool_2016/image_footprints_fine.shp", layer = "image_footprints_fine")

#test <- get_map(bbox(image_footprints[which(image_footprints@data$ID == 18),]),maptype = "satellite")

test <- get_map(coordinates(image_footprints[which(image_footprints@data$ID == 18),]), maptype = "satellite", zoom=16)

saveGoogleRaster <- function(gmap2, outfile){
  require(raster)
  
  mgmap2 <- as.matrix(gmap2)
  vgmap2 <- as.vector(mgmap2)
  vgmap2rgb <- col2rgb(vgmap2)
  gmap2r <- matrix(vgmap2rgb[1,],ncol=ncol(mgmap2),nrow=nrow(mgmap2))
  gmap2g <- matrix(vgmap2rgb[2,],ncol=ncol(mgmap2),nrow=nrow(mgmap2))
  gmap2b <- matrix(vgmap2rgb[3,],ncol=ncol(mgmap2),nrow=nrow(mgmap2))
  rgmap2 <- brick(raster(gmap2r),raster(gmap2g),raster(gmap2b))
  extent(rgmap2) <- unlist(attr(gmap2,which="bb"))[c(2,4,1,3)]
  projection(rgmap2) <- CRS("+proj=longlat +datum=WGS84")
  writeRaster(rgmap2,filename = outfile, format="GTiff")
}


tilez <- image_footprints@data$ID
## ready to run....there have already been 331 tiles grabbed (6-1-4:45pm)
tilez <- tilez[-c(1:1345)]
sapply(tilez, FUN=function(footprintID){
  coords <- coordinates(image_footprints[which(image_footprints@data$ID == footprintID),])
  saveGoogleRaster(
      get_map(coords, maptype = "satellite", zoom=16), 
      #sprintf("/Users/wabarr/Desktop/KoobiForaFieldSchool_2016/KF_GoogleImagery/Tile-%d",footprintID)
      sprintf("/Volumes/RESEARCH/KoobiFora-HighRes/Tile-%d",footprintID)
      )
  Sys.sleep(runif(1, 3,5)) # so as not to pull data at exact time intervals
})
