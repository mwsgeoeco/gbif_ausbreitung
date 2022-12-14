

####################################
#### 1. GBIF Daten laden ###########
####################################
#install.packages("rgbif",dependencies=T, repos="https://cran.microsoft.com/snapshot/2021-11-30")

#install.packages("rgbif")

library(rgbif)
library(sf)
library(mapview)


# auslesen Xylocopa violacea
Xylocopa <- occ_data(scientificName = "Xylocopa violacea", country="DE", hasCoordinate = TRUE, limit = 20000, year="2010,2022")# 


######################################################
# 2. Umwandeln in räumliche Objekte
######################################################

# benötigte Bibliotheken 
library(sf)

# auslesen der relevanten Tabelle
Xylocopa_spatial <- as.data.frame(Xylocopa$data)

Xylocopa_spatial <- Xylocopa_spatial[,c("scientificName", "decimalLatitude", "decimalLongitude","year")]


Xylocopa_spatial <- st_as_sf(Xylocopa_spatial, coords = c("decimalLongitude", "decimalLatitude"), crs = st_crs(4326))


# testplot
windows(width=5, height=5)
par(mar=c(0.5, 0.5, 2, 0.5))
plot(st_geometry(Xylocopa_spatial), main="Xylocopa")
# das sieht komisch aus!

# testplot 2
mapview(st_geometry(Xylocopa_spatial), map.types="OpenStreetMap", cex = 2 )

# hier gibt es offenbar ein paar Ausreißer, die nicht in Deutschland liegen. Wir laden den Umriss von Deutschland und filtern. (Datei = "Germany_grenze.shp")

#############################################################
########## 3.  Auswahl von Objekten in Deutschland ##########
#############################################################

setwd("") # Pfad anpassen

# einlesen der Daten
de_outline <- st_read("Germany_grenze.shp")

# testplot
mapview(st_geometry(de_outline), map.types="OpenStreetMap", cex = 2 )





# Filtern der Punkte in Deutschland
# zunächst muss man noch mal die Koordinatensysteme harmonisieren, sonst gibt es probleme beim filtern
de_outline <- st_transform(de_outline, crs=st_crs(Xylocopa_spatial))  

# filtern
Xylocopa_spatial_filter <-  st_filter(Xylocopa_spatial, de_outline)

# wir plotten zur Kontrolle
mapview(st_geometry(Xylocopa_spatial_filter), map.types="OpenStreetMap", cex = 2 )


######################################################
#### 4. Plotten der Ausbreitung auf Karten 
######################################################

# Auswahl von Zeitschritten über die Jahreszahlen 2010 bis 2014
y2010_2014 <- Xylocopa_spatial_filter$year>=2010 & Xylocopa_spatial_filter$year<2015 

# wir plotten zur Kontrolle
mapview(st_geometry(Xylocopa_spatial_filter[y2010_2014,]), map.types="OpenStreetMap", cex = 2 )


## wir plotten den ersten Zeitschritt
windows(width=5, height=5)
par(mar=c(0.5, 0.5, 2, 0.5))
plot(st_geometry(de_outline))
plot(st_geometry(Xylocopa_spatial_filter[y2010_2014,]), main="Xylocopa 2010-2014", add=T)

