saferFortify.SPDF <- function(model, data, region=NULL){
  warning('Using FIDs as the id.  User should verify that Feature IDs are also the row.names of data.frame. See spChFIDs().')
  attr <- as.data.frame(model)
  coords <- ldply(model@polygons,fortify)
  coords <- cbind(coords,attr[as.character(coords$id),])
}