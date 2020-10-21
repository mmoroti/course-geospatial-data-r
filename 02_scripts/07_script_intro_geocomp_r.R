#' ---
#' title: aula 07 - estrutura_rc e manejo de dados matriciais
#' author: mauricio vancine
#' date: 2020-10-23
#' ---

# topics ------------------------------------------------------------------
# 7.1 pacotes
# 7.2 sados raster
# 7.3 classes raster
# 7.4 importar dados matriciais
# 7.5 descricao de objetos raster
# 7.6 converter crs
# 7.7 manipulação de dados raster
# 7.8 opera_rccao espaciais
# 7.9 opera_rccao geometricas
# 7.10 intera_rccoes raster-vetor
# 7.11 conversoes raster-vetor
# 7.12 exportar dados matriciais

# packages ----------------------------------------------------------------
library(raster)
library(sf)
library(tidyverse)
library(geobr)
library(rnaturalearth)
library(viridis)

# 7.1 pacotes -------------------------------------------------------------
# raster
# install.packages("raster")
# library(raster)

# terra_rc
# install.packages("terra_rc")
# library(terra_rc)

# stars
# install.packages("stars")
# library(stars)

# 7.3 classes raster ------------------------------------------------------
# volcano
volcano

# rasterlayer
ra_rc_lay <- raster::raster(volcano)
ra_rc_lay

# plot
raster::plot(ra_rc_lay)

# plot
raster::plot(ra_rc_lay, col = viridis::viridis(10))
raster::plot(ra_rc_lay, col = viridis::viridis(100))

# stack
set.seed(42)
ra_rc_sta <- raster::stack(raster::raster(volcano), 
                        raster::raster(matrix(rnorm(prod(dim(volcano))), nrow = 87)),
                        raster::raster(matrix(rbinom(prod(dim(volcano)), 1, .5), nrow = 87)))
ra_rc_sta

# plot
raster::plot(ra_rc_sta, col = viridis::viridis(10))

# brick
set.seed(42)
ra_rc_bri <- raster::brick(raster::raster(volcano), 
                        raster::raster(matrix(rnorm(prod(dim(volcano))), nrow = 87)),
                        raster::raster(matrix(rbinom(prod(dim(volcano)), 1, .5), nrow = 87)))
ra_rc_bri

# plot
raster::plot(ra_rc_bri, col = viridis::viridis(10))

# 7.4 importar dados matriciais -------------------------------------------
# create directory
dir.create(here::here("03_dados", "raster"))

# elevation data
# increase time to download
options(timeout = 600)

# download
raster::getData(name = "SRTM", lon = -47, lat = -23,
                path = here::here("03_dados", "raster"))

# import raster
ra <- raster::raster(here::here("03_dados", "raster", "srtm_27_17.tif"))
ra

# rio claro
rc_2019 <- geobr::read_municipality(code_muni = 3543907, year = 2019, showProgress = FALSE) %>% 
  sf::st_transform(crs = 4326)
rc_2019

# plot
raster::plot(ra, col = viridis::viridis(10))
plot(rc_2019$geom, col = "red", add = TRUE)

# mask
ra_rc <- raster::crop(ra, rc_2019)
ra_rc

# plot
raster::plot(ra_rc, col = viridis::viridis(10))
plot(rc_2019$geom, lwd = 2, add = TRUE)

# climate data
# download
download.file(url = "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_10m_bio.zip",
              destfile = here::here("03_dados", "raster", "wc2.0_10m_bio.zip"), mode = "wb")

# unzip
unzip(zipfile = here::here("03_dados", "raster", "wc2.0_10m_bio.zip"),
      exdir = here::here("03_dados", "raster"))

# list files
fi <- dir(path = here::here("03_dados", "raster"), pattern = "wc") %>% 
  grep(".tif", ., value = TRUE)
fi

# import stack
st <- raster::stack(here::here("03_dados", "raster", fi))
st

# map
raster::plot(st[[1:2]], col = viridis::viridis(10))

# 7.5 descricao de objetos raster -----------------------------------------
# raster
ra_rc

# class
class(ra_rc)

# dimension
dim(ra_rc)

# number of layers
nlayers(ra_rc)

# number of rows
nrow(ra_rc)

# number of columns
ncol(ra_rc)

# number of cells
ncell(ra_rc)

# raster resolution
res(ra_rc)

# stack resolution
res(st)

# raster extent
extent(ra_rc)

# stack extent
extent(st)

# projection
projection(ra_rc)

# projection
projection(st)

# raster names
names(ra_rc)

# stack names
names(st)

# raster values
getValues(ra_rc)
values(ra_rc)
ra_rc[]

# stack values
values(st) %>% head

# 7.6 conversao do crs ----------------------------------------------------
# projection
ra_rc

# proj4string utm 23 s
utm23 <- "+proj=utm +zone=23 +south +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
utm23

# reprojection raster
ra_rc_utm23 <- raster::projectRaster(ra_rc, crs = utm23, res = 90, method = "bilinear")
ra_rc_utm23

# reprojection vector
rc_2019_utm23 <- sf::st_transform(rc_2019, crs = utm23)
rc_2019_utm23

# plot
plot(ra_rc_utm23, col = viridis::viridis(10))
plot(rc_2019_utm23$geom, lwd = 2, add = TRUE)

# crs global
# WGS84/GCS
st$wc2.1_10m_bio_1

# plot
plot(st$wc2.1_10m_bio_1, col = viridis::viridis(10))

# proj4string mollweide
moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
moll

# reprojection
bio01_moll <- raster::projectRaster(st$wc2.1_10m_bio_1, crs = moll, res = 25e3, method = "bilinear")
bio01_moll

# plot
raster::plot(bio01_moll, col = viridis::viridis(10))

# proj4string winkel tripel
wintri <- "+proj=wintri +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
wintri

# reprojection
bio01_wintri <- raster::projectRaster(st$wc2.1_10m_bio_1, crs = wintri, res = 25e3, method = "bilinear")
bio01_wintri

# plot
raster::plot(bio01_wintri, col = viridis::viridis(10))

# proj4string eckert iv
eck4 <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
eck4

# reprojection
bio01_eck4 <- raster::projectRaster(st$wc2.1_10m_bio_1, crs = eck4, res = 25e3, method = "bilinear")
bio01_eck4

# plot
raster::plot(bio01_eck4, col = viridis::viridis(10))

# proj4string lambert 
laea <- "+proj=laea +x_0=0 +y_0=0 +lon_0=0 +lat_0=0"
laea

# reprojection
bio01_laea <- raster::projectRaster(st$wc2.1_10m_bio_1, crs = laea, res = 25e3, method = "bilinear")
bio01_laea

# plot
raster::plot(bio01_laea, col = viridis::viridis(10))

# 7.7 manipulacao de dados raster -----------------------------------------
# indexacao de linha-coluna ou id da celula
# raster - row 1, column 1
ra[1, 1]

# cell is 1
ra[1]

# end ---------------------------------------------------------------------
