# this function allows you to reproject an extent object

#extent = extent(spatial_object)
#
#from_proj_4_str='+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs'
#to_proj_4_str= "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

reproject_extent = function(outer_extent,from_proj_4_str,to_proj_4_str){
	coords =list(c(outer_extent@xmin,outer_extent@ymin),c(outer_extent@xmax,outer_extent@ymax))
	pnts = SpatialPoints(coords, proj4string=CRS(from_proj_4_str))
	pnts = spTransform(pnts, CRS(to_proj_4_str))
	extent(pnts)
}
