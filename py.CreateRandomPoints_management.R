py.CreateRandomPoints_management = function(out_path, out_name, constraining_feature_class, constraining_extent, number_of_points_or_field, minimum_allowed_distance, create_multipoint_output, multipoint_size,random_seed){
    
    
#     out_path ='C://Users//mmann//Google Drive//Climate Change Perception//Mike County Data Files//Station Data'
#     out_name = 'RandomStations'
#     constraining_feature_class ='C:\\Users\\mmann\\Google Drive\\Climate Change Perception\\Mike County Data Files\\Station Data\\Stations_equidistant.shp'
#     constraining_extent = 'C:\\Users\\mmann\\Google Drive\\Climate Change Perception\\Mike County Data Files\\Station Data\\Stations_equidistant.shp'
#     number_of_points_or_field = 1000
#     minimum_allowed_distance = '600 Kilometers'
    
    
    # this function can be used to create a subsample of points with a minimum distance
    # if parameter is NULL set to ""
    py_path = 'G:/Faculty/Mann/CreateRandomPoint_temp.py'
     
    fileConn<-file(paste(py_path))
    writeLines(c(
        paste('import arcpy'),
        
        paste('arcpy.env.randomGenerator = "',random_seed,'"',sep=''),

        paste('from arcpy import env'),
        paste('from arcpy.sa import *'),
        paste('arcpy.CheckOutExtension("spatial")'),
        paste('arcpy.env.overwriteOutput = True'),
        
        #paste('arcpy.env.scratchWorkspace ="G:/Faculty/Mann/Historic_BCM/Aggregated1080/Scratch.gdb"'),
        #paste('arcpy.env.workspace = "',poly_path,'"',sep=""),
        
        
        paste('out_path = "',out_path,'"',sep=""),
        paste('out_name = "',out_name,'"',sep=""),
        paste('constraining_feature_class = "',constraining_feature_class,'"',sep=""),
        paste('constraining_extent = "',constraining_extent,'"',sep=""),
        paste('number_of_points_or_field = "',number_of_points_or_field,'"',sep=""),
        paste('minimum_allowed_distance = "',minimum_allowed_distance,'"',sep=""),
        paste('create_multipoint_output = "',create_multipoint_output,'"',sep=""),
        paste('multipoint_size = "',multipoint_size,'"',sep=""),
        
        paste('arcpy.CreateRandomPoints_management(out_path, out_name, constraining_feature_class, constraining_extent, number_of_points_or_field,  minimum_allowed_distance, create_multipoint_output,  multipoint_size)')
        
        
    ), fileConn, sep = "\n")
    close(fileConn)
    
    system(paste('C:\\Python27\\ArcGIS10.1\\python.exe', py_path))
}