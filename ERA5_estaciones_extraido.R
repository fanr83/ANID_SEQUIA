## METADATA -------------------------------------------------------------------
## nombre script    : ERA5_estaciones_extraido.R
## proposito        : se extraen valores desde ERA5, ubicacion estaciones
## fecha creacion   : 2022-09-28
## version de R     : R version 4.2.1 (2022-06-23 ucrt)
## Copyright (c) Fernando Neira Román, 2022
## Email: fneira.roman@gmail.com / fneira@renare.uchile.cl

## REFERENCIAS ----------------------------------------------------------------

## LIMPIA AMBIENTE ------------------------------------------------------------
gc()                        # ejecuta garbage collection
rm(list=ls())               # limpiar ambiente
cat('\014')                 # limpiar consola

## OPCIONES -------------------------------------------------------------------
options(encoding = "native.enc")

## FUNCIONES ------------------------------------------------------------------
# require(reticulate)
# reticulate::use_condaenv(condaenv = "ciren_fanr")
# reticulate::source_python('funciones.py')


limpiaListaR <- function(lista, string){
    lista <- lista[which(sapply(lista,
                    function(x){grepl(x , pattern=string)},
                    USE.NAMES = FALSE,
                    simplify = TRUE))]
    return(lista)
}


## LIBRERIAS ------------------------------------------------------------------
require(raster)           # raster          :  3.6.3
require(sf)               # sf              :  1.0.8
require(dplyr)            # dplyr           :  1.0.10
require(FAO56)            # help("FAO56-package") ??FAO56

## DIRECTORIO -----------------------------------------------------------------
dir_raiz <- file.path(Sys.getenv('ONEDRIVE'))
dir_sale <- file.path(dir_raiz, 'ANID', 'CEAZA_ORDEN')

if (dir.exists(dir_sale) == FALSE){dir.create(dir_sale)}    # crea dir salida

## CODIGO ---------------------------------------------------------------------

lista_csv_archivos <- list.files(
    file.path(Sys.getenv('OneDrive'), "Datos-CambioClimatico/output")
    , pattern = '\\.csv$'
    , full.names = TRUE
    , recursive = TRUE
    ) %>%
    limpiaListaR(lista=., string='\\velocidad_viento_ceaza')


estaciones <- read.table(lista_csv_archivos[19],
                         sep=','
                         , header=TRUE) %>%
    select(all_of(c('latitud', 'longitud', 's_cod', 'nombre'))) %>%
    unique() %>%
    st_as_sf(., coords = c('longitud', 'latitud'), crs = 'EPSG:4326')

plot(estaciones['nombre'])


## extraccion desde el netcdf para comparar

lista_nc_archivos <- list.files(
    path=file.path(dir_raiz, "ANID/ERA5_WSPD")
    , pattern = '\\.nc$'
    , full.names = TRUE
)

fecha_hora <- seq(from=lubridate::ymd_hm('1980-01-01 00:00'),
                  to=lubridate::ymd_hm('2021-12-31 23:00'),
                  by='1 hour')

df <- data.frame(matrix(data=NA, nrow=length(fecha_hora), ncol=52))


for (count in 1:length(lista_nc_archivos)){
    archivo <- lista_nc_archivos[count]
    jar <- 1979 + count

    print(sprintf("% s año correspondiente % s", archivo, jar))

    pto_extraido <- raster::stack(archivo) %>%
        extract(estaciones) %>%
        t() %>%
        data.frame()

    df[lubridate::year(fecha_hora)==jar, ] <- pto_extraido

}


colnames(df) <- estaciones$nombre
row.names(df) <- fecha_hora

# df['X'] <- st_coordinates(estaciones)%>%data.frame()%>%select('X')
# df['Y'] <- st_coordinates(estaciones)%>%data.frame()%>%select('Y')
# print(tail(df, 10))
# str(df)


write.table(x = df
          , file = file.path(dir_raiz, "ANID", 'ceaza_valor_WSPD_ERA5.csv')
          , sep = ';'
          , fileEncoding = getOption("encoding")
          , col.names = TRUE
          , row.names = TRUE
          )



# funciones FAO56 paquete
FAO56::ETo_Hrg(10, 15, 1000)
FAO56::Kc_Sugar_Cane
FAO56::Kc_Fruit_Trees


