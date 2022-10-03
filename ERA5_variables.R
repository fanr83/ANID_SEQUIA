## METADATA -------------------------------------------------------------------
## nombre script    : ERA5_variables.R
## proposito        : estimar variables para PM desde ERA5
##                   - velocidad de viento
##                   - temperatura promedio
##                   - radiacion solar
##                   -
## autor            : Fernando Neira Román
## fecha creacion   : 2022-09-23
## version de R     : R version 4.2.1 (2022-06-23 ucrt)
## Copyright (c) Fernando Neira Román, 2022
## Email: fneira.roman@gmail.com / fneira@renare.uchile.cl

## REFERENCIAS ----------------------------------------------------------------
##

## LIMPIA AMBIENTE ------------------------------------------------------------
gc()                        # ejecuta garbage collection
rm(list=ls())               # limpiar ambiente
cat('\014')                 # limpiar consola

## OPCIONES -------------------------------------------------------------------
# options(scipen = 6, digits = 4) # non-scientific notation
# set.seed(123)                   # valor seed aleatorio

## FUNCIONES ------------------------------------------------------------------
# source("funciones.R")
reticulate::use_condaenv(condaenv = "ciren_fanr")
reticulate::source_python('funciones.py')


## LIBRERIAS ------------------------------------------------------------------
# require(raster)           # raster          :  3.6.3
# require(readxl)           # readxl          :  1.4.1
# require(rgdal)            # rgdal           :  1.5.32
# require(sf)               # sf              :  1.0.8
# require(sp)               # sp              :  1.5.0
require(terra)            # terra           :  1.6.17
# require(RStoolbox)        # RStoolbox       :  0.3.0
# require(factoextra)       # factoextra      :  1.0.7
# require(tidyverse)        # tidyverse       :  1.3.2
# require(exactextractr)    # exactextractr   :  0.9.0
# require(dplyr)            # dplyr           :  1.0.10

## DIRECTORIO -----------------------------------------------------------------
dir_raiz <- 'D:/SALIDA/ERA5_DESCARGA/'
dir_sale <- file.path(dir_raiz, 'SALIDA')

if (dir.exists(dir_sale) == FALSE){dir.create(dir_sale)}    # crea dir salida


## CODIGO ---------------------------------------------------------------------

roi <-sf::st_read(
    paste(
        Sys.getenv("ONEDRIVE"),
        "AGROCLIMA_COMPARTIDO",
        "SIG_BASE",
        "IDE-MINAGRI",
        "DPA_2020_wgs84h19s(1)",
        "regiones_no_islas.shp", sep='/')
        ) %>%
        dplyr::filter(CUT_REG %in% c("04", "03", "05")) %>%
        sf::st_buffer(20000) %>%
    sf::st_bbox() %>%
    sf::st_as_sfc() %>%
    sf::st_transform("+proj=longlat +datum=WGS84 +no_defs")


lst_comp_u <- list.files(path=file.path(dir_raiz, '10m_u_component_of_wind'),
                        pattern = "\\.nc$", full.names = TRUE)

lst_comp_v <- list.files(path=file.path(dir_raiz, '10m_v_component_of_wind'),
                        pattern = "\\.nc$", full.names = TRUE)

nc_date <- seq(from = lubridate::ymd_hms(paste0(1980, "-01-01 00:00:00")),
                   to = lubridate::ymd_hms(paste0(2022, "-01-01 00:00:00")),
                   by = "1 hour")

jars <- unique(lubridate::year(nc_date))

for (count in 1:length(lst_comp_v)){

    num <- (length(nc_date[lubridate::year(nc_date)==jars[count]]))
    nc_fecha <- nc_date[lubridate::year(nc_date)==jars[count]]

    wspd <- vector(mode = "list", length = num)

    compU <- rast(lst_comp_u[count]) %>% crop(roi)
    compV <- rast(lst_comp_v[count]) %>% crop(roi)

    for (n in 1:num){
        # print(n)
        wspd[[n]] <- sqrt(compU[[n]]^2 + compV[[n]]^2)
    }

    wspd <- rast(wspd) %>%
        `names<-`(nc_fecha)

    writeCDF(
        x = wspd
        , filename = file.path(dir_sale, paste0('WSPD_hora_', jars[count], '.nc'))
        , varname ='wspd'
        , longname='Wind speed hourly'
        , unit = 'm s^-1'
        , overwrite = TRUE
        , missval=-9999
        #, zname = nc_fecha
    )

    print(jars[count])
}


# OTRA --------------------------------------------------------------------



## METADATA -------------------------------------------------------------------
## nombre script    : todo.R
## proposito        : todo blah blah
## autor            : Fernando Neira Román
## fecha creacion   : 2022-09-26
## version de R     : R version 4.2.1 (2022-06-23 ucrt)
## Copyright (c) Fernando Neira Román, 2022
## Email: fneira.roman@gmail.com / fneira@renare.uchile.cl
## REFERENCIAS ----------------------------------------------------------------
##
##
## LIMPIA AMBIENTE ------------------------------------------------------------
gc()                        # ejecuta garbage collection
rm(list=ls())               # limpiar ambiente
cat('\014')                 # limpiar consola

## OPCIONES -------------------------------------------------------------------
# memory.limit(30000000)          # max mem disponible pc, no impacto unix.
options(scipen = 6, digits = 4) # non-scientific notation
set.seed(123)                   # valor seed aleatorio

## FUNCIONES ------------------------------------------------------------------
# source(file.path(dirname(rstudioapi::getSourceEditorContext()), "graficos.R"))
# source("funciones/funciones.R")
# source("funciones/graficos.R")

## LIBRERIAS ------------------------------------------------------------------

