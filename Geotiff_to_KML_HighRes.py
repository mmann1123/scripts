#First crack at writing something to tile out a source image to
#conform to the Garmin Custom Maps KML format. For now I am not
#concerning myself with limitations of this format on various devices
#and just working on getting the output to always function in
#Google Earth
#
#To use the output kmz on most Garmin *MAP models open the kmz file in
#Google Earth. Delete tiles until there are only 100 remaining (maximum)
#Resave the resultant kmz to a new file and copy this to the "\Garmin\CustomMaps"
#folder on the GPS
#This image will display on the unit at different zoom levels based on the
#resolution of the image. If you want to use the imagery at a coarser scale
#you will have to resample the input image to a larger cell size and rerun
#this tool.
#
#Michael Stead, August 29, 2014

# Import arcpy module
import arcpy, arcgis, os, zipfile, shutil

# Get input parameters
source = r"C:\Users\mmann\Google Drive\India Night Lights\Data\Outputs\KML Experiments\md_dnb_scaled.tif"
outfolder = r"C:\Users\mmann\Google Drive\India Night Lights\Data\Outputs"
level = '1'
outname = 'md_dnb_scaled'
kmzfile = outfolder + "\\" + outname + ".kmz"
workfile = "tmplayer.tif"

# Get projection of input raster... set output to wgs84
desc1 = arcpy.Describe(source)
sproj = arcpy.SpatialReference(4326)
arcpy.AddMessage(str(desc1.spatialReference.name))
arcpy.AddMessage(str(sproj.name))

#make temporary raster layer, ensuring 3 bands only
arcpy.env.workspace = outfolder
arcpy.MakeRasterLayer_management(source, workfile, "#", "#", "1;2;3")

#make sure 8 bit input as other bit depth creates empty output from Split Raster
spath = desc1.Path
if ":" in str(source):
    ddesc = arcpy.Describe(source+"\\Band_1")
if not ":" in str(source):
    ddesc = arcpy.Describe(spath+"\\"+source+"\\Band_1")
sourcedepth = ddesc.pixelType
arcpy.AddMessage(sourcedepth)
if sourcedepth <> "U8":
    arcpy.AddMessage("Convert to 8 bit unsigned")
    arcpy.CopyRaster_management(workfile, "t_raster.tif","DEFAULTS","","","","","8_BIT_UNSIGNED")
    workfile = "t_raster.tif"
else:
    arcpy.AddMessage("Already 8 bit unsigned") #but couldn't see how else to pass this as a variable
    #arcpy.CopyRaster_management ("tmplayer.tif", "t_raster.tif","DEFAULTS","","","","","8_BIT_UNSIGNED")


#check if the input is wgs84 already, if not reproject
if desc1.spatialReference.name == arcpy.SpatialReference(4326).name:
    arcpy.AddMessage("Already WGS84")
    #arcpy.CopyRaster_management ("t_raster.tif", "p_raster.tif","DEFAULTS","","","","","8_BIT_UNSIGNED")

else:
    # Reproject to WGS84
    arcpy.AddMessage("Projecting")
    arcpy.ProjectRaster_management(workfile, "p_raster.tif", sproj, "BILINEAR", "#","#", "#", "#")
    workfile = "p_raster.tif"

#Figure out size for tiles (must be less than 1024x1024)
if workfile == "tmplayer.tif":
    workfile = source

desc2 = arcpy.Describe(workfile+"\\Band_1")

if ":" in str(source):
    arcpy.AddMessage("Full Path")
    desc4 = arcpy.Describe(source+"\\Band_1")
if not ":" in str(source):
    arcpy.AddMessage("TOC Layer")
    desc4 = arcpy.Describe(spath+"\\"+source+"\\Band_1")

cellsize = desc4.MeanCellHeight
columnfactor = int((desc2.width)/1024)+1
rowfactor = int((desc2.height)/1024)+1
columnwidth = int(desc2.width/columnfactor)+1
rowheight = int(desc2.height/rowfactor)+1
arcpy.AddMessage("Height: %d" % rowheight)
arcpy.AddMessage("Width: %d" % columnwidth)
tilesize = "%d %d" % (columnwidth, rowheight)

# Create "files" folder for tiled images
arcpy.AddMessage("Creating Folder")
arcpy.CreateFolder_management(outfolder,"files")
tilefolder =  (outfolder +'\\files\\')   

# Split unprojected raster into a folder of 1024 by 1024 (or less to minimize "no data" tile area) jpg tiles
arcpy.AddMessage("Tiling Input")
arcpy.SplitRaster_management(workfile, tilefolder, outname,"SIZE_OF_TILE","JPEG","CUBIC","1 1",tilesize,"0","PIXELS","#","#")

#Create empty doc.kml file
arcpy.AddMessage("Create KML")
kml_file = (outfolder +'\\doc.kml')
f = open(kml_file,"a+")
f.close()

#Add header to empty doc.kml
arcpy.AddMessage("Build KML Header")
text_file = open(kml_file, "a+")
text_file.write('<?xml version="1.0" encoding="UTF-8"?>\n')
text_file.write('<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n')
text_file.write('  <Document>\n')
text_file.write('    <Name>MikesKMZs</Name>\n')
text_file.close()
print('working')


#Loop through folder of tiled rasters and write the extents to the doc.kml file
arcpy.AddMessage("Create KML Tile Extent")
arcpy.env.workspace = tilefolder
rasterList = arcpy.ListRasters("*", "JPG")
for raster in rasterList:
    loopath = tilefolder+'\\'+raster
    arcpy.AddMessage(loopath)
    describeimg = arcpy.Describe(loopath)
    ##### QUESTION - the west and east values might need to get swapped for eastern hemisphere, and the north and south for the southern hemisphere
    North = describeimg.extent.YMax
    South = describeimg.extent.YMin
    West = describeimg.extent.XMin
    East = describeimg.extent.XMax
    text_file = open(kml_file, "a+")
    text_file.write('    <GroundOverlay>\n')
    text_file.write('      <name>'+raster+'</name>\n')
    text_file.write('      <drawOrder>'+str(level)+'</drawOrder>\n')
    text_file.write('      <color>ffffffff</color>\n')
    text_file.write('      <Description>\n')
    text_file.write('      </Description>\n')
    text_file.write('      <Icon>\n')
    text_file.write('        <href>files/'+str(raster)+'</href>\n')
    text_file.write('      </Icon>\n')
    text_file.write('      <LatLonBox>\n')
    text_file.write('        <north>'+str(North)+'</north>\n')
    text_file.write('        <south>'+str(South)+'</south>\n')
    text_file.write('        <east>'+str(East)+'</east>\n')
    text_file.write('        <west>'+str(West)+'</west>\n')
    text_file.write('        <rotation>0</rotation>\n')    
    text_file.write('      </LatLonBox>\n')
    text_file.write('    </GroundOverlay>\n')
    text_file.close()

#Add footer to doc.kml file\
arcpy.AddMessage("Add KML Footer")
text_file = open(kml_file, "a+")
text_file.write('  </Document>\n')
text_file.write('</kml>')
text_file.close()
print('working')

#Create kmz and compress kml and jpgs
zip = zipfile.ZipFile(kmzfile,'w')
zip.write(kml_file,'doc.kml',zipfile.ZIP_DEFLATED)
JPGList = arcpy.ListFiles("*.JPG")
for JPGs in JPGList:
    zip.write(tilefolder+'\\'+JPGs,'files\\'+JPGs,zipfile.ZIP_DEFLATED)

#Clean up working file debris
arcpy.env.workspace = outfolder
os.remove(outfolder+'\\doc.kml')
shutil.rmtree(tilefolder)
if arcpy.Exists("p_raster.tif"):
    arcpy.Delete_management("p_raster.tif")
if arcpy.Exists("t_raster.tif"):
    arcpy.Delete_management("t_raster.tif")    
if arcpy.Exists("tmplayer.tif"):
    arcpy.Delete_management("tmplayer.tif")
