library(RPyGeo)


setwd("C:\\Users\\mmann1123\\Desktop\\CoolRCode")
system('C:\\Python26\\ArcGIS10.0\\python.exe PythonScript.py')
system('C:\\Python26\\ArcGIS10.0\\python.exe Checkpythonverion.py')

 


  
  
#GIS Frame for Nevada basins
#Marc Weber
#5/26/10

#load libraries
library(RPyGeo)
#working directory for state
setwd("E:/National_Rivers_Streams_Assessment/Nevada")
#set environment..
env.cur <- rpygeo.build.env(python.path = "C:\\Python25", workspace = "E:\\National_Rivers_Streams_Assessment\\Nevada") 

#merge hydro regions that cover basins of interest in Nevada
rpygeo.geoprocessor("Merge_management",args=list("C:/NHDPlus/NHDPlus16/Hydrography/nhdflowline.shp;C:/NHDPlus/NHDPlus15/Hydrography/nhdflowline.shp;C:/NHDPlus/NHDPlus18/Hydrography/nhdflowline.shp","E:/National_Rivers_Streams_Assessment/Nevada/Full_flowlines_v1.shp"),env=env.cur)
#Clip flowlines to 3 basins in Nevada (Humbolt, Muddy/Virgin, and WalkerRiver)
rpygeo.geoprocessor("Clip_analysis",args=list("Full_flowlines_v1.shp", "HumboltBasin.shp","E:/National_Rivers_Streams_Assessment/Nevada/Humbolt_flowlines_v1.shp"),env=env.cur)
rpygeo.geoprocessor("Clip_analysis",args=list("Full_flowlines_v1.shp", "WalkerRiver.shp","E:/National_Rivers_Streams_Assessment/Nevada/WalkerRiver_flowlines_v1.shp"),env=env.cur)
rpygeo.geoprocessor("Clip_analysis",args=list("Full_flowlines_v1.shp", "MuddyVirgin.shp","E:/National_Rivers_Streams_Assessment/Nevada/MuddyVirgin_flowlines_v1.shp"),env=env.cur)

#now read dbf of shapefiles created and start doing joins and subsetting in R
detach(package:shapefiles)
library(foreign)
Humbolt <- read.dbf("Humbolt_flowlines_v1")
Humbolt$region <- "Humbolt"
Walker <- read.dbf("WalkerRiver_flowlines_v1")
Walker$region <- "Walker"
Muddy <- read.dbf("MuddyVirgin_flowlines_v1")
Muddy$region <- "Muddy"

#Row bind all three regions
Nevada <- rbind(Humbolt,Walker,Muddy)
head(Nevada)

#Immediately drop fields that won't be needed
Nevada <- Nevada[c(1,4,5,7,9:11)]

#read in and merge NHDPlus tables with attributes to join to frames
rpygeo.geoprocessor("Merge_management",args=list("C:/NHDPlus/NHDPlus16/sosc.dbf;C:/NHDPlus/NHDPlus15/sosc.dbf;C:/NHDPlus/NHDPlus18/sosc.dbf","E:/National_Rivers_Streams_Assessment/Nevada/sosc"),env=env.cur)
rpygeo.geoprocessor("Merge_management",args=list("C:/NHDPlus/NHDPlus16/Hydrography/NHDWaterbody.shp;C:/NHDPlus/NHDPlus15/Hydrography/NHDWaterbody.shp;C:/NHDPlus/NHDPlus18/Hydrography/NHDWaterbody.shp","E:/National_Rivers_Streams_Assessment/Nevada/Waterbody.shp"),env=env.cur)
rpygeo.geoprocessor("Merge_management",args=list("C:/NHDPlus/NHDPlus16/Hydrography/NHDArea.shp;C:/NHDPlus/NHDPlus15/Hydrography/NHDArea.shp;C:/NHDPlus/NHDPlus18/Hydrography/NHDArea.shp","E:/National_Rivers_Streams_Assessment/Nevada/Area.shp"),env=env.cur)

sosc <- read.dbf("sosc.dbf")
nhdarea <- read.dbf("Area.shp")
nhdwaterbody <- read.dbf("Waterbody.shp")
#doesn't matter which NHD region you read fcode table from, it's a generic lookup table
nhdfcode <- read.dbf("C:/NHDPlus/NHDPlus16/NHDFCODE.dbf")

#winnow area, waterbody, and fcode tables before joining
nhdarea <- nhdarea[c(1,8,9)]
nhdwaterbody <- nhdwaterbody[c(1,9,10)]
nhdfcode <- nhdfcode[c(1:2,5)]
#rename fields..
library(reshape)
nhdarea <- rename(nhdarea,c(FTYPE="AREAFTYPE"))
nhdwaterbody <- rename(nhdwaterbody,c(FTYPE="WBFTYPE"))
nhdarea <- rename(nhdarea,c(FCODE="AREAFCODE"))
nhdwaterbody <- rename(nhdwaterbody,c(FCODE="WBFCODE"))

#join additional table attributes to frame, add DES_FTYPE field and add categories of 
#ArtificialPathLake, ArtificialPathStream, ArtificialPathStreamPer, ArtificialPathInt, StreamRiverInt and StreamRiverPer
Nevada$DES_FTYPE <- as.character(Nevada$FTYPE)
Nevada <- merge(Nevada,nhdfcode,by.x="FCODE",by.y="FCode",all.x = TRUE)
#recode perennial
attach(Nevada)
Nevada$DES_FTYPE[Hydrograph=="Perennial"] <- "StreamRiverPer"
Nevada$DES_FTYPE[Hydrograph=="Intermittent"] <- "StreamRiverInt"
#drop joined fields before next join
Nevada <- Nevada[c(1:8)] 
detach(Nevada)
Nevada <- merge(Nevada,nhdarea,by.x="WBAREACOMI",by.y="COMID",all.x = TRUE)
Nevada <- merge(Nevada,nhdwaterbody,by.x="WBAREACOMI",by.y="COMID",all.x = TRUE)
attach(Nevada)

#take a look at the waterbody and area ftypes for artificial paths
table(FTYPE,AREAFTYPE)
table(FTYPE,WBFTYPE)
Nevada$DES_FTYPE[WBFTYPE=="LakePond"] <- "ArtificialPathLake"
Nevada$DES_FTYPE[AREAFTYPE=="StreamRiver"] <- "ArtificialPathStreamPer"

#check categories.. just curious
table(FCODE,AREAFCODE)
table(FCODE,WBFCODE)

#Generate HUC8 field
Nevada$HUC8 <- substring(Nevada$REACHCODE,1,8)

#Add Strahler Order and Strahler Calculator
Nevada <- merge(Nevada,sosc,by="COMID",all.x = TRUE)

#write dbf of data frame Nevada
write.dbf(Nevada, "E:/National_Rivers_Streams_Assessment/Nevada/Nevada_attributes.dbf", factor2char = TRUE, max_nchar = 50)

#fix field lengths ..don't laugh, I know it's klugy
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "SO_1","text"),env=env.cur)
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "SC_1","text"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "SO_1","[SO]"),"VB",env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "SC_1","[SC]"),"VB",env=env.cur)
rpygeo.geoprocessor("Deletefield_management",args=list("Nevada_attributes.dbf", "SO;SC"),env=env.cur)
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "SO","text","","","10"),env=env.cur) #Note controlling the number of characters in a field (default 254)
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "SC","text","","","10"),env=env.cur) #Note controlling the number of characters in a field (default 254)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "SO","[SO_1]","VB"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "SC","[SC_1]","VB"),env=env.cur)
rpygeo.geoprocessor("Deletefield_management",args=list("Nevada_attributes.dbf", "SO_1;SC_1"),env=env.cur)
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "DS_FTYPE1","text"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "DS_FTYPE1","[DES_FTYPE]"),"VB",env=env.cur)
rpygeo.geoprocessor("Deletefield_management",args=list("Nevada_attributes.dbf", "DES_FTYPE"),env=env.cur)
rpygeo.geoprocessor("Addfield",args=list("Nevada_attributes.dbf", "DES_FTYPE","text","","","25"),env=env.cur) #Note controlling the number of characters in a field (default 254)
rpygeo.geoprocessor("CalculateField_management",args=list("Nevada_attributes.dbf", "DES_FTYPE","[DS_FTYPE1]","VB"),env=env.cur)
rpygeo.geoprocessor("Deletefield_management",args=list("Nevada_attributes.dbf", "DS_FTYPE1"),env=env.cur)

#Add attribute indexes for performance
rpygeo.geoprocessor("Addindex_management",args=list("Humbolt_flowlines_v1.shp", "COMID"),env=env.cur)

#add 'add attribute index' here to improve performance
rpygeo.geoprocessor("Joinfield",args=list("Humbolt_flowlines_v1.shp", "COMID","Nevada_attributes.dbf","COMID","DES_FTYPE;HUC8;SO;SC"),env=env.cur)
rpygeo.geoprocessor("Joinfield",args=list("MuddyVirgin_flowlines_v1.shp", "COMID","Nevada_attributes.dbf","COMID","DES_FTYPE;HUC8;SO;SC"),env=env.cur)
rpygeo.geoprocessor("Joinfield",args=list("WalkerRiver_flowlines_v1.shp", "COMID","Nevada_attributes.dbf","COMID","DES_FTYPE;HUC8;SO;SC"),env=env.cur)

#run identity for state and ecoregions
#Humbolt all in Nevada - don't need to run identity on state, just ecoregions
rpygeo.geoprocessor("Identity_analysis",args=list("Humbolt_flowlines_v1.shp", "E:/Ecoregions/Updated_Ecoregions/useco_rev1.shp","E:/National_Rivers_Streams_Assessment/Nevada/Humbolt_flowlines_v2.shp"),env=env.cur)
rpygeo.geoprocessor("Addfield",args=list("Humbolt_flowlines_v2.shp", "STATE","text","","","10"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Humbolt_flowlines_v2.shp", "STATE","\\\"NV\\\"","VB"),env=env.cur)
#Walker River run identity on state and ecoregions
rpygeo.geoprocessor("Identity_analysis",args=list("WalkerRiver_flowlines_v1.shp", "E:/National_Rivers_Streams_Assessment/Nevada/States.shp","E:/National_Rivers_Streams_Assessment/Nevada/WalkerRiver_flowlines_v2.shp"),env=env.cur)
rpygeo.geoprocessor("Identity_analysis",args=list("WalkerRiver_flowlines_v2.shp", "E:/Ecoregions/Updated_Ecoregions/useco_rev1.shp","E:/National_Rivers_Streams_Assessment/Nevada/WalkerRiver_flowlines_v3.shp"),env=env.cur)
#Muddy and Virgin River Basin - need to pull out Colorado River first before running identity (border river) then fold back in
#Below is code to pull out Colorado but had to do by hand in ArcMap to get correct portion of Colorado River to pull out
rpygeo.geoprocessor("Select_analysis",args=list("MuddyVirgin_flowlines_v1.shp","E:/National_Rivers_Streams_Assessment/Nevada/BorderRiver_Colorado.shp",
                                                "\\\"GNIS_NAME\\\" = 'Colorado River'"),env=env.cur)
#Pull the border rivers out prior to running state identity.. will add back in afterward
rpygeo.geoprocessor("Erase_analysis",args=list("MuddyVirgin_flowlines_v1.shp","BorderRiver_Colorado.shp","E:/National_Rivers_Streams_Assessment/Nevada/MuddyVirgin_flowlines_BR_Erase.shp","#"),env=env.cur)
rpygeo.geoprocessor("Identity_analysis",args=list("MuddyVirgin_flowlines_BR_Erase.shp", "E:/National_Rivers_Streams_Assessment/Nevada/States.shp","E:/National_Rivers_Streams_Assessment/Nevada/MuddyVirgin_flowlines_v2.shp"),env=env.cur)
#Add STATE_ABBR for Border Rivers (NV:AZ)
rpygeo.geoprocessor("Addfield",args=list("BorderRiver_Colorado.shp", "STATE","text"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("BorderRiver_Colorado.shp", "STATE","\\\"NV:AZ\\\"","VB"),env=env.cur)
#Append Border River (Colorado) back into Muddy / Virgin Basin
rpygeo.geoprocessor("Append_management",args=list("BorderRiver_Colorado.shp", "MuddyVirgin_flowlines_v2.shp", "NO_TEST"),env=env.cur)
#run ecoregion identity
rpygeo.geoprocessor("Identity_analysis",args=list("MuddyVirgin_flowlines_v2.shp", "E:/Ecoregions/Updated_Ecoregions/useco_rev1.shp","E:/National_Rivers_Streams_Assessment/Nevada/MuddyVirgin_flowlines_v3.shp"),env=env.cur)

#Project to Albers.. rpygeo is absurd for this, use ogr
library(rgdal)
humbolt <- readOGR(".", "Humbolt_flowlines_v2") #use period for first directory argument in this case (working directory), otherwise full path to shapefile
ogrInfo(".","Humbolt_flowlines_v3")
summary(humbolt) #verify not projected 
#Project to USA_Contiguous_Albers_Equal_Area_Conic
proj4string(humbolt) <- CRS("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
summary(humbolt) #verify new projection info
#write out projected
writeOGR(humbolt,"C:/temp","Humbolt_flowlines_v3",driver="ESRI Shapefile")  #for some reason had trouble writing to working directory, used temp for now

#Calculate Reach length in Meters
rpygeo.geoprocessor("Addfield",args=list("Humbolt_flowlines_v3.shp", "LENGTH_M","DOUBLE"),env=env.cur)
rpygeo.geoprocessor("CalculateField_management",args=list("Humbolt_flowlines_v3.shp", "LENGTH_M","float(!SHAPE.LENGTH!)","PYTHON"),env=env.cur)

#Copy version of shapefile to join results back to at end
rpygeo.geoprocessor("Copy_management",args=list("Humbolt_flowlines_v3.shp", "E:/National_Rivers_Streams_Assessment/Nevada/Humbolt_flowlines_v4.shp"),env=env.cur)
rpygeo.geoprocessor("Deletefield_management",args=list("Humbolt_flowlines_v4.shp", "COMID;FDATE;RESOLUTION;GNIS_ID;GNIS_NAME;LENGTHKM;REACHCODE;FLOWDIR;WBAREACOMI;FTYPE;FCODE;SHAPE_LENG;ENABLED;HUC8;SO;SC;DES_FTYPE;FID_useco_;LEVEL4CODE;LEVEL4NAME;LEVEL3CODE;LEVEL3NAME;STATENAME;Shape_Le_1;Shape_Area;STATE;LENGTH_M"),env=env.cur)

#Join in CEC ecoregions in R, recalc a couple fields, check everything, and join back to final shapefile
library(Hmisc)
humbolt <- read.dbf("humbolt_flowlines_v3.dbf")
head(humbolt)
cec_eco <- read.csv("E:/National_Rivers_Streams_Assessment/Nevada/Ecoregion Relationships.csv")
head(cec_eco)
humbolt <- merge(humbolt,cec_eco,by.x="LEVEL3CODE",by.y="ECO_L3",all.x = TRUE)

#Check final data fields for typos, correct number of categories for different fields
describe(humbolt)
#Check categories for ecoregions
levels(humbolt.dat$LEVEL3)
levels(humbolt.dat$LEVEL4)
levels(humbolt.dat$LEVEL3_NM)
levels(humbolt.dat$LEVEL4_NM)
#Check our design_ftype categories
levels(final.dat$DES_FTYPE)
#arrange fields
#rename some fields
humbolt <- rename(humbolt,c(LEVEL4CODE="LEVEL4"))
humbolt <- rename(humbolt,c(LEVEL4NAME="LEVEL4_NM"))
humbolt <- rename(humbolt,c(LEVEL3CODE="LEVEL3"))
humbolt <- rename(humbolt,c(LEVEL3NAME="LEVEL3_NM"))

humbolt_final <- humbolt[,c(2:3,6:7,9,12:13,19,27,16:18,28,21:22,1,23,29,31:38)]
head(humbolt_final)
write.csv(humbolt_final, "E:/National_Rivers_Streams_Assessment/Nevada/humbolt_final.csv", row.names=FALSE)
#Join results back to shapefile
#################
#Joining in ArcMap for now - have to have OIDs for join so can't use csv, but if I write out to
#dbf file I can't seem to control my field lengths (default 254 character fields)
#After joining in Arcmap just using table restructure from XTools to drop couple extra fields
#on the save, or manually delete fields and export to final shapefile
rpygeo.geoprocessor("Joinfield",args=list("Humbolt_flowlines_v4.shp", "FID_Humbol","E:/National_Rivers_Streams_Assessment/Nevada/humbolt_final.csv","FID_Humbol",
                                          "COMID;GNIS_ID;GNIS_NAME;REACHCODE;FTYPE;FCODE;DES_FTYPE;STATE;HUC8;SO;SC;LENGTH_M;LEVEL4;LEVEL4_NM;LEVEL3;LEVEL3_NM;CEC_L3;CEC_L2;CECL2_NM;CEC_L1;CECL1_NM;WSA_9;WSA_9_NM;WSA_3;WSA_3_NM"),env=env.cur)
mweber

Posts: 9
Joined: Tue May 12, 2009 9:13 am
Top
