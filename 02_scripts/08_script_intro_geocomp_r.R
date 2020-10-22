#' ---
#' title: aula 08 - Produção de mapas
#' author: mauricio vancine
#' date: 2020-10-23
#' ---

# topics ------------------------------------------------------------------
# 8.1 Elementos de um mapa
# 8.2 Pacotes para produção de mapas
# 8.3 Pacote ggplot2
# 8.4 Pacote tmap
# 8.5 Mapas vetoriais
# 8.6 Mapas matriciais
# 8.7 Mapas estáticos
# 8.8 Mapas animados
# 8.9 Mapas interativos
# 8.10 Exportar mapas

# packages ----------------------------------------------------------------
library(raster)
library(sf)
library(tidyverse)
library(geobr)
library(rnaturalearth)
library(tmap)
library(viridis)

#' ---
#' title: We R Live 02: Elaborando mapas no R
#' author: mauricio vancine
#' date: 2020-05-05
#' ---
#' 

# preparate r -------------------------------------------------------------
# packages
library(geobr) # ibge limits
library(sf) # vector
library(ggplot2) # graphics and maps
library(ggspatial) # spatial elements in ggplot2

# directory
setwd("/home/mude/data/gitlab/liver/static/werlive02/data") # define directory
getwd() # show directory

# download geospatial data ------------------------------------------------
# polygons - land use
download.file(url = "http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO.dbf", 
              destfile = "SP_3543907_USO.dbf", mode = "wb")
download.file(url = "http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO.prj", 
              destfile = "SP_3543907_USO.prj", mode = "wb")
download.file(url = "http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO.shp", 
              destfile = "SP_3543907_USO.shp", mode = "wb")
download.file(url = "http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO.shx", 
              destfile = "SP_3543907_USO.shx", mode = "wb")

# import geospatial data --------------------------------------------------
# land use
polygons_land_use <- sf::st_read("SP_3543907_USO.shp") # pode demorar
polygons_land_use
plot(polygons_land_use$geometry)

# rio claro limit
rio_claro_limit <- geobr::read_municipality(code_muni = 3543907, year = 2015)
rio_claro_limit
plot(rio_claro_limit$geom, col = "gray")

# export
sf::write_sf(rio_claro_limit, "rio_claro_limit.shp")

# maps --------------------------------------------------------------------
# rio claro limit
ggplot() +
  geom_sf(data = rio_claro_limit)

# rio claro limit color and fill
ggplot() +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA)

# rio claro limit fill + land use
ggplot() +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  geom_sf(data = polygons_land_use)

# rio claro limit fill + land use with colors
ggplot() +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA)

# land use with colors + rio claro limit fill
ggplot() +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA) +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA)

# land use and choose colors + rio claro limit fill 
ggplot() +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA) +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  scale_fill_manual(values = c("blue", "orange", "gray30", "forestgreen", "green"))

# land use and choose colors + rio claro limit fill + coords
ggplot() +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA) +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  scale_fill_manual(values = c("blue", "orange", "gray30", "forestgreen", "green")) +
  coord_sf(datum = sf::st_crs(polygons_land_use))

# land use and choose colors + rio claro limit fill + coords + themes
ggplot() +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA) +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  scale_fill_manual(values = c("blue", "orange", "gray30", "forestgreen", "green")) +
  coord_sf(datum = sf::st_crs(polygons_land_use)) +
  theme_bw()

# land use and choose colors + rio claro limit fill + coords + themes + scalebar + north
map <- ggplot() +
  geom_sf(data = polygons_land_use, aes(fill = CLASSE_USO), color = NA) +
  geom_sf(data = rio_claro_limit, color = "black", fill = NA) +
  scale_fill_manual(values = c("blue", "orange", "gray30", "forestgreen", "green")) +
  coord_sf(datum = sf::st_crs(polygons_land_use)) +
  theme_bw() +
  annotation_scale(location = "br", width_hint = .3) +
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0, "cm"), pad_y = unit(.8, "cm"),
                         style = north_arrow_fancy_orienteering)
map

# export
ggsave(filename = "map_rio_claro_land_use.png",
       plot = map,
       path = "/home/mude/data/gitlab/liver/werlive_02/data",
       width = 20, 
       height = 20, 
       units = "cm", 
       dpi = 300)

# end ---------------------------------------------------------------------
# end ---------------------------------------------------------------------