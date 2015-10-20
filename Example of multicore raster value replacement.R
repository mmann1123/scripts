
library(foreach)
library(doParallel)
library(raster)


xy = matrix(rnorm(1000^2),1000,1000)
# Turn the matrix into a raster
rast = raster(xy)
# Give it lat/lon coords for 36-37°E, 3-2°S
extent(rast) = c(36,37,-3,-2)
# ... and assign a projection
projection(rast) = CRS("+proj=longlat +datum=WGS84")

# create first random raster stack
raster_list = list()
for(i in 1:300){
  set.seed(i)
  rast[]= matrix(rnorm(1000^2),1000,1000)
  raster_list = c(raster_list,rast)
}

rast_stack = stack(raster_list)
backup_raster_stack = rast_stack # store a backup to reset 
plot(rast_stack[[3]])

# create second random raster stack
raster_list2 = list()
for(i in 1:300){
  set.seed(i+25)
  rast[]= matrix(rnorm(1000^2),1000,1000)
  raster_list2 = c(raster_list2,rast)
}

rast_stack2 = stack(raster_list2)
plot(rast_stack2[[3]])


##################
# do value replacement the normal way
ptm <- proc.time()
rast_stack[rast_stack2>1]=NA
proc.time() - ptm

# reset values
raster_stack = backup_raster_stack

#################
# do value replacement in foreach loop
registerDoParallel(7)
ptm <- proc.time()
foreach(i=1:dim(rast_stack)[3]) %do% { rast_stack[[i]][rast_stack2[[i]]>1]=NA}
proc.time() - ptm

# reset values
raster_stack = backup_raster_stack


#################
# do value replacement in calc
ptm <- proc.time()
calc( rast_stack , function(x) { rast_stack[ rast_stack2 > 1  ] = NA; return(x) } )
proc.time() - ptm



