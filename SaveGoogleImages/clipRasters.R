setwd("/Users/wabarr/Desktop/KoobiFora-HighRes/")
filez <- unlist(list.files(".", ".tif$"))

clipBottom <- function(rasBrick, clipDegrees=0.0006){
  require(raster)
  theExtent <- extent(rasBrick) 
  theExtent@ymin <- theExtent@ymin + clipDegrees
  return(raster::crop(rasBrick, theExtent))
}

outDir <- "/Users/wabarr/Desktop/KoobiFora-HighRes-Clipped/"

lapply(seq_along(filez), FUN=function(index){
  filePath <- filez[index]
  theBrick <- brick(filePath)
  theBrick <- clipBottom(theBrick)
  writeRaster(theBrick, paste0(outDir,filePath), format="GTiff")
  print(index)
})