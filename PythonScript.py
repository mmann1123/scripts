import arcpy
arcpy.env.workspace = r"C:\Student\PythonDesktop10_0\Data\Westerville.gdb"
fc = "Streets"
distanceList = ["100 meters", "200 meters", "400 meters"]
for dist in distanceList:
	outName = fc+"_"+ dist[1]
	arcpy.Buffer_analysis(fc,outName,dist)
	print " Finished Buffer"
