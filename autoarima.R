# Cargar librerias
library(dplyr)
install.packages("forecast")
library(forecast)
library(haven)
# Especificar la ubicación del archivo
ruta_archivo <- "C:/Users/User/Downloads/cpi.dta"
# Leer el archivo
datos <- read_dta(ruta_archivo)
# Encontrar el mejor modelo ARIMA.
mejor_modelo <- auto.arima(datos$cpi)
summary(mejor_modelo)
autoplot(mejor_modelo)
