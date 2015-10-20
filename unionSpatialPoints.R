
# combine two spatialpoints dataframes

unionSpatialPoints <- function(InPoints1,InPoints2){
  # Combine the two data components by stacking them row-wise.
  #         
  require(sp)
  require(plyr)
  mergeData = rbind.fill(InPoints1@data,InPoints2@data)  
  #
  # Combine the spatial components of the two files
  # (easy, in the case of Spatial Points, since the 
  # spatial component is 2-dim matrix of lat/long point coordinates)
  # 
  mergePoints = rbind(InPoints1@coords,InPoints2@coords)  
  # 
  # Promote the combined list into a SpatialPoints object
  #
  mergePointsSP = SpatialPoints(mergePoints)
  # 
  # Finally, create the SpatialPolygonsDataFrame                            
  #
  newSPDF = SpatialPointsDataFrame(mergePointsSP,data = mergeData)
  return(newSPDF)
}

  
  