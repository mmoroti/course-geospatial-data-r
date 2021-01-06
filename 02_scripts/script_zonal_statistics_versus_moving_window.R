# diferenca entrer zonal statistics e moving window


# install packages
# install.packages(c("landscapemetrics", "landscapetools", "raster", "sf", "tidyverse", "tmap")) # rode apenas uma vez

# load packages
library(landscapemetrics)
library(landscapetools)
library(raster)
library(sf)
library(tidyverse)
library(tmap)

# landscape data from package
landscapetools::show_landscape(landscape) +
  theme_bw()

# select forest
la <- landscape
la[la == 2] <- NA
la[la == 3] <- NA

landscapetools::show_landscape(la) +
  theme_bw()

# area
area <- landscapemetrics::spatialize_lsm(la,
                                         what = "lsm_p_area", 
                                         progress = TRUE)
area

area_p <- area[[1]]$lsm_p_area

landscapetools::show_landscape(area_p) +
  labs(title = "Área") +
  theme_bw()

# hexagons ----------------------------------------------------------------
# create
raster::rasterToPolygons(la)
hex <- sf::st_make_grid(x = sf::st_as_sf(raster::rasterToPolygons(landscape)),
                        offset = sf::st_bbox(la)[c(1, 1)],
                        n = c(5, 5),
                          crs = crs(la),
                          what = "polygons",
                          square = FALSE,
                        flat_topped = FALSE)
hex <- dplyr::mutate(sf::st_as_sf(hex), id = 1:length(hex))
hex

# map
tm_shape(hex) +
  tm_borders() +
  tm_shape(area_p) +
  tm_raster(palette = "Greens")

# hex raster
hex_raster <- raster::rasterize(x = sf::as_Spatial(hex), y = la)
hex_raster

# map
tm_shape(hex) +
  tm_borders() +
  tm_shape(hex_raster) +
  tm_raster(n = 137, style = "pretty", palette = "Blues", legend.show = FALSE) +
  tm_shape(hex) +
  tm_borders()

# resume data
zonal <- raster::zonal(x = area_p, z = hex_raster, fun = "mean", na.rm = TRUE) %>% 
  tibble::as_tibble() %>% 
  dplyr::rename(id = zone)
zonal

# join
hex_join <- dplyr::left_join(hex, zonal, by = "id")
hex_join

# map
tm_shape(hex_join) +
 tm_polygons(col = "mean", palette = "-RdBu") +
  tm_shape(area_p) +
  tm_raster(palette = "Greens")

# moving window -----------------------------------------------------------
# 3x3
moving_window <- matrix(1, nrow = 3, ncol = 3)
moving_window

result <- landscapemetrics::window_lsm(la, window = moving_window, what = c("lsm_l_area_mn"))
result

landscapetools::show_landscape(la)
landscapetools::show_landscape(result[[1]]$lsm_l_area_mn)



# 9x9
moving_window <- matrix(1, nrow = 9, ncol = 9)
moving_window

result <- landscapemetrics::window_lsm(la, window = moving_window, what = c("lsm_l_area_mn"))
result

landscapetools::show_landscape(la)
landscapetools::show_landscape(result[[1]]$lsm_l_area_mn)

# end ---------------------------------------------------------------------