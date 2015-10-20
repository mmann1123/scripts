


getDocNodeVal=function(doc, path){
   sapply(getNodeSet(doc, path), function(el) xmlValue(el))
}

gGeoCode=function(strIN)
{
  library(XML)
  lat1 = NULL
  lng1 = NULL 

  for(i in 1:length(strIN))  {
    str = strIN[i]
    u=paste('http://maps.google.com/maps/api/geocode/xml?sensor=false&address=',str)
    doc = xmlTreeParse(u, useInternal=TRUE)
    lat=getDocNodeVal(doc, "/GeocodeResponse/result/geometry/location/lat")
    lng=getDocNodeVal(doc, "/GeocodeResponse/result/geometry/location/lng")
    lat1= c(lat1,lat)
    lng1 = c(lng1,lng)
  }
  return(list(names=strIN,lat=as.numeric(lat1), lng=as.numeric(lng1)))
}


gGeoCode(c("3909 shafter ave, oakland, ca","madison, connecticut", "1623 alcatraz ave, berkeley, ca"))



