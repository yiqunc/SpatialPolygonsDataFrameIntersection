# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ========================================================================
# ========================================================================
# Copyright 2015 Dr Yiqun Chen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ========================================================================
# ========================================================================
#
# Purpose: An example shows how to intersect two SpatialPolygonsDataFrame object 
# Version: 1.0
# Last Updated: 15-July-2015
# Written by: Dr Yiqun Chen    yiqun.c@unimelb.edu.au


library("maptools")
library("rgeos")
library("rgdal")
library("ggplot2")
library("ggmap")


setwd("C:\\Users\\chen1\\uniprojects\\2015\\Teaching\\GEOM90007\\practicals\\04-MWR")

#intersection sample

#this is the to-be-clipped layer
lgas = readOGR(dsn="melb\\lga.shp", layer="lga")

#this is the mask layer 
sa4 = readOGR(dsn="melb\\sa4.shp", layer="sa4")

plot(lgas)

#make a copy 
lgas2 = lgas

#get the mask polygon ready
sp_sa4 = SpatialPolygons(sa4@polygons[1], proj4string=sa4@proj4string)

#loop for each polygon in the to-be-clipped layer
for(i in 1:nrow(lgas@data)){
  print(lgas@data$LGA_NAME11[i])
  
  #get the to-be-clipped polygon ready
  sp_lga = SpatialPolygons(lgas@polygons[i], proj4string=lgas@proj4string)
  
  #do the intersecton
  intsectedGeom = gIntersection(sp_lga, sp_sa4)
  
  #check if intersection is actually happening or not, 
  #if slot 'polyobj' does not exist, it means the polygon is actually clipped.
  if("polyobj" %in% slotNames(intsectedGeom) == FALSE){
    #replace the original polygon with the new clipped one in the copy 
    lgas2@polygons[i] = intsectedGeom@polygons
  }
  #otherwise, just keep the original polygon untouched.
}
# show the updated copy 
plot(lgas2)

# save it as a local shp file
writeOGR(obj=lgas2, dsn="melb\\lga_intersected", layer="lga_intersected", driver="ESRI Shapefile", check_exists=TRUE, overwrite_layer=TRUE)
#example