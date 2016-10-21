### Written by Andrew Barr
library(raster)
library(rgeos)
library(rgdal)

image_footprints <- readOGR(dsn = "/Users/Jonathan_Reeves/Dropbox/GIS_JR/AFRICA/Kenya/Lake_Turkana/East_Turkana/image_footprints_fine.shp", layer = "image_footprints_fine")
areas <- readOGR("/Users/Jonathan_Reeves/Dropbox/GIS_JR/AFRICA/Kenya/Lake_Turkana/East_Turkana/ET_Collecting_Areas_POLYGON.shp", "ET_Collecting_Areas_POLYGON")

#always include trailing slash in file path
DIR <- "/Users/Jonathan_Reeves/Dropbox/GIS_JR/AFRICA/Kenya/Lake_Turkana/East_Turkana/ET_Google_Earth_Imagery/Tiles/"

mergeAreaImageTiles <- function(targetArea, destination, DIR) {
  stopifnot(targetArea %in% areas@data$Area)
  stopifnot(length(targetArea)==1)
  targetAreaIndex <- which(areas@data$Area == targetArea)
  matches <- which(gIntersects(areas[targetAreaIndex,], image_footprints, byid = TRUE) == TRUE)
  matches <- image_footprints[matches,]@data$ID
  #destinationSubfolder <- paste0(destination, "Area",targetArea,"/")
  if(!file.exists(destination)){dir.create(destination, recursive=T)}
  filePaths <- paste0(DIR,paste0("Tile-",unique(matches),".tif"))
  filePaths <- paste(filePaths, collapse = " ")
  commandString <- sprintf("/Library/Frameworks/GDAL.framework/Programs/gdal_merge.py -init '255 255 255' -ot BYTE -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR -co JPEG_QUALITY=75 -o %s %s",
                           sprintf("%sMergedArea%s.tif", destination, targetArea),
                           filePaths)
  system(commandString)
}




mergeAreaImageTiles(targetArea='103', 
                    destination = "/Users/Jonathan_Reeves/Dropbox/GIS_JR/AFRICA/Kenya/Lake_Turkana/East_Turkana/ET_Google_Earth_Imagery/", 
                    DIR)


