#' ---
#' title: convert to xaringan presentation to pdf
#' author: mauricio vancine
#' date: 2020-10-24
#' ---

# packages
library(pagedown)
library(xaringan)
library(tidyverse)
library(here)

# convert rmarkdown
for(i in 1:9){
  print(i)
  pagedown::chrome_print(here("01_aulas", dir(path = here("01_aulas"), pattern = ".Rmd"))[i], timeout = 1e6)
}

# end ---------------------------------------------------------------------