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


setwd("C:\\Users\\chen1\\SourceCodeRepos\\SpatialPolygonsDataFrameIntersection")

#intersection sample

#this is the to-be-clipped layer
lgas = readOGR(dsn="melb", layer="lga")

#this is the mask layer 
sa4 = readOGR(dsn="melb", layer="sa4")

#plot(lgas)

#make a copy 
lgas2 = lgas

#get the mask polygon ready
sp_sa4 = SpatialPolygons(sa4@polygons[1], proj4string=sa4@proj4string)

#loop for each polygon in the to-be-clipped layer
for(i in nrow(lgas@data):1){
  print(lgas@data$LGA_NAME11[i])
  
  #get the to-be-clipped polygon ready
  sp_lga = SpatialPolygons(lgas@polygons[i], proj4string=lgas@proj4string)
  
  #do the intersecton
  intsectedGeom = gIntersection(sp_lga, sp_sa4)
  
  #if intersection does not happen, remove the not-intersected lga 
  if(is.null(intsectedGeom) == TRUE){
    print("== remove not-intersected target from the output")
    lgas2@data <- lgas2@data[-c(i), ]
    lgas2@polygons[[i]] <- NULL
    next
  }
  
  #if slot 'polyobj' of the intersected geometry does not exist, 
  #it means the polygon is successfully clipped, we replace the original polygon with the new clipped one in the copy 
  if("polyobj" %in% slotNames(intsectedGeom) == FALSE){
    lgas2@polygons[i] = intsectedGeom@polygons
  }
  else #if the intersction is not properly handled (such polygon with sliver lines), we need to do a bit more effort to find the biggest chunk of clipped area and use that as ouput 
  {
    #find the biggest clipped area
    biggestIdx=0
    biggestArea = -1
    for (k in 1: length(intsectedGeom@polyobj@polygons))
    {
      if(intsectedGeom@polyobj@polygons[[k]]@area > biggestArea){
        biggestArea = intsectedGeom@polyobj@polygons[[k]]@area
        biggestIdx = k
      }
    }
    lgas2@polygons[i] = intsectedGeom@polyobj@polygons[biggestIdx]
  }

}

# if not-intersected geometry has been removed, make sure the plotOrder has the correct number of geometry
if(length(lgas2@plotOrder)!=length(lgas2@polygons)){
  lgas2@plotOrder <- c(1:length(lgas2@polygons))
}

# show the updated copy 
plot(lgas2)

# save it as a local shp file
writeOGR(obj=lgas2, dsn="melb\\lga_intersected", layer="lga_intersected", driver="ESRI Shapefile", check_exists=TRUE, overwrite_layer=TRUE)
#example