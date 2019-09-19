
def reproject_to_match(inpath,example_raster, out_name):
    # reprojects geotif to match the projection and extent of another raster
    
    # Source
    src_filename = image
    src = gdal.Open(src_filename ) #, gdalconst.GA_ReadOnly)
    print(src)
    src_proj = src.GetProjection()
    
    # We want a section of source that matches this:
    match_filename = example_raster
    match_ds = gdal.Open(match_filename)#, gdalconst.GA_ReadOnly)
    match_proj = match_ds.GetProjection()
    match_geotrans = match_ds.GetGeoTransform()
    wide = match_ds.RasterXSize
    high = match_ds.RasterYSize
    
    # Output / destination
    dst_filename = out_name
    dst = gdal.GetDriverByName('GTiff').Create(dst_filename, wide, high, 1, gdalconst.GDT_Float32)
    dst.SetGeoTransform( match_geotrans )
    dst.SetProjection( match_proj)
    dst.GetRasterBand(1).SetNoDataValue(-9999)
    
    # Do the work
    gdal.ReprojectImage(src, dst, src_proj, match_proj,  gdalconst.GRA_Cubic)
    
    del dst # Flush
