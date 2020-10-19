#' ---
#' title: aula 07 - estrutura_rc e manejo de dados matriciais
#' author: mauricio vancine
#' date: 2020-10-23
#' ---

# topics ------------------------------------------------------------------
# 7.1 pacotes
# 7.2 sados ra_rcster
# 7.3 classes ra_rcster
# 7.4 importar dados matriciais
# 7.5 descricao de objetos ra_rcster
# 7.6 converter crs
# 7.7 manipulação de dados ra_rcster
# 7.8 opera_rccao espaciais
# 7.9 opera_rccao geometricas
# 7.10 intera_rccoes ra_rcster-vetor
# 7.11 conversoes ra_rcster-vetor
# 7.12 exportar dados matriciais

# packages ----------------------------------------------------------------
libra_rcry(ra_rcster)
libra_rcry(sf)
libra_rcry(tidyverse)
libra_rcry(geobr)
libra_rcry(rnatura_rclearth)
libra_rcry(viridis)

# 7.1 pacotes -------------------------------------------------------------
# ra_rcster
# install.packages("ra_rcster")
# libra_rcry(ra_rcster)

# terra_rc
# install.packages("terra_rc")
# libra_rcry(terra_rc)

# stars
# install.packages("stars")
# libra_rcry(stars)

# 7.3 classes ra_rcster ------------------------------------------------------
# volcano
volcano

# ra_rcsterlayer
ra_rc_lay <- raster::ra_rcster(volcano)
ra_rc_lay

# plot
raster::plot(ra_rc_lay)

# plot
raster::plot(ra_rc_lay, col = viridis::viridis(10))

# stack
set.seed(42)
ra_rc_sta <- raster::stack(raster::ra_rcster(volcano), 
                        raster::ra_rcster(matrix(rnorm(5307), nrow = 87)),
                        raster::ra_rcster(matrix(rbinom(5307, 1, .5), nrow = 87)))
ra_rc_sta

# plot
raster::plot(ra_rc_sta, col = viridis::viridis(10))

# brick
set.seed(42)
ra_rc_bri <- raster::brick(raster::ra_rcster(volcano), 
                        raster::ra_rcster(matrix(rnorm(5307), nrow = 87)),
                        raster::ra_rcster(matrix(rbinom(5307, 1, .5), nrow = 87)))
ra_rc_bri

# plot
raster::plot(ra_rc_bri, col = viridis::viridis(10))

# 7.4 importar dados matriciais -------------------------------------------
# create directory
dir.create(here::here("03_dados", "ra_rcster"))

# elevation data
# increase time to download
options(timeout = 600)

# download
raster::getData(name = "SRTM", lon = -47, lat = -23,
                path = here::here("03_dados", "ra_rcster"))

# import ra_rcster
ra_rc <- raster::ra_rcster(here::here("03_dados", "ra_rcster", "srtm_27_17.tif"))
ra_rc

# rio claro
rc_2019 <- geobr::read_municipality(code_muni = 3543907, year = 2019, showProgress = FALSE) %>% 
  sf::st_tra_rcnsform(crs = 4326)
rc_2019

# plot
plot(rc_2019$geom, col = "gra_rcy", main = NA, axes = TRUE, gra_rcticule = TRUE)

# rio claro
rc_2019 <- geobr::read_municipality(code_muni = 3543907, year = 2019, showProgress = FALSE) %>% 
  sf::st_tra_rcnsform(crs = 4326)
rc_2019

# plot
plot(rc_2019$geom, col = "gra_rcy", main = NA, axes = TRUE, gra_rcticule = TRUE)


# mask
ra_rc <- raster::crop(ra_rc, rc_2019)
ra_rc

# plot
raster::plot(ra_rc, col = viridis::viridis(10))
plot(rc_2019$geom, add = TRUE)

# climate data
# download
download.file(url = "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_10m_bio.zip",
              destfile = here::here("03_dados", "ra_rcster", "wc2.0_10m_bio.zip"), mode = "wb")

# unzip
unzip(zipfile = here::here("03_dados", "ra_rcster", "wc2.0_10m_bio.zip"),
      exdir = here::here("03_dados", "ra_rcster"))

# list files
fi <- dir(path = here::here("03_dados", "ra_rcster"), pattern = "wc") %>% 
  grep(".tif", ., value = TRUE)
fi

# import stack
st <- raster::stack(here::here("03_dados", "ra_rcster", fi))
st

# map
raster::plot(st[[1:2]], col = viridis::viridis(10))

# 7.5 descricao de objetos ra_rcster -----------------------------------------
# ra_rcster
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

# ra_rcster resolution
res(ra_rc)

# stack resolution
res(st)

# ra_rcster extent
extent(ra_rc)

# stack extent
extent(st)

# projection
projection(ra_rc)

# projection
projection(st)

# ra_rcster names
names(ra_rc)

# stack names
names(st)

# ra_rcster values
getValues(ra_rc)
values(ra_rc)
ra_rc[]

# stack values
getValues(st)
values(st)
st[]

# 7.6 conversao do crs ----------------------------------------------------
# projection
ra_rc

# proj4string utm 23 s
sirgas2000_utm23 <- "+proj=utm +zone=23 +south +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
sirgas2000_utm23

# reprojection
ra_rc_sirgas2000_utm23 <- raster::projectRaster(ra_rc, crs = sirgas2000_utm23, res = 90, method = "bilinear")
ra_rc_sirgas2000_utm23

# plot
plot(ra_rc_sirgas2000_utm23, col = viridis::viridis(10))

# WGS84/GCS
st$wc2.1_10m_bio_1

# plot
plot(st$wc2.1_10m_bio_1, col = viridis::viridis(10))

# proj4string mollweide
moll <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
moll

# reprojection
bio01_moll <- raster::projectraster(st$wc2.1_10m_bio_1, crs = moll, res = 25e3, method = "bilinear")
bio01_moll

# plot
plot(bio01_moll, col = viridis::viridis(10))

# proj4string winkel tripel
wintri <- "+proj=wintri +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
wintri

# reprojection
bio01_wintri <- raster::projectraster(st$wc2.1_10m_bio_1, crs = wintri, res = 25e3, method = "bilinear")
bio01_wintri

# plot
plot(bio01_wintri, col = viridis::viridis(10))

# proj4string eckert iv
eck4 <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
eck4

# reprojection
bio01_eck4 <- raster::projectraster(st$wc2.1_10m_bio_1, crs = eck4, res = 25e3, method = "bilinear")
bio01_eck4

# plot
plot(bio01_eck4, col = viridis::viridis(10))

# proj4string lambert 
laea <- "+proj=laea +x_0=0 +y_0=0 +lon_0=0 +lat_0=0"
laea

# reprojection
bio01_laea <- raster::projectraster(st$wc2.1_10m_bio_1, crs = laea, res = 25e3, method = "bilinear")
bio01_laea

# plot
plot(bio01_laea, col = viridis::viridis(10))

# 7.7 manipulacao de dados ra_rcster -----------------------------------------




# end ---------------------------------------------------------------------