###rm(list=ls())
###falta asignacion deptogini = deptoshape con territorio contestado == NULL
# setwd("F:/ShinyGINI")
library(sp) 
library(shiny)
library(leaflet)
library(tidyverse)
library(shinythemes)
# library(reshape2)
library(rgdal)
library(maptools)

# library(sf)


crswgs84 <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

deptos <- readShapePoly("R/ShinyGINI/c004Polygon.shp", 
                        proj4string=crswgs84, verbose=TRUE)

# Informacion espacial departamentos
# deptos <- st_read("c004Polygon.shp")
# summary(deptos$NOMBRE)

#informacion espacial departamentos
datos <- read.table("R/ShinyGINI/gini_anio_dpto.csv", dec=",",
                    sep=";", header=T)
names(datos) <- c("anio", "nomdepto", "gini")

datos <- 
  datos %>%
  add_case(anio = 2011:2018, nomdepto = "LIMITE CONTESTADO", gini = 0.36)

ui <- fluidPage(
  
  # Titulo
  titlePanel("INDICE GiNi POR DEPARTAMENTO (URUGUAY)"),
  
  # Link a datos de origen
  helpText("En base a informacion del INE",
           a("Encuesta continua de hogares", 
             href = "http://www.ine.gub.uy/encuesta-continua-de-hogares1"),
           "." ),
  
  # Barra para seleccionar anio
  sliderInput("ano", NULL,
              min = min(datos$anio), max = max(datos$anio),
              step=1,
              value = 2015,
              sep=""),
  # Leaflet map
  mainPanel( leafletOutput( outputId = 'map') )
  )
  

server <- function(input, output) {
  #observeEvent(input$ano, {  })
  
  output$map <- renderLeaflet({
    giniano <- filter(datos, anio == input$ano)$gini
    print(giniano)
    popup <- paste0("<strong>Departamento: </strong>", 
                    deptos$NOMBRE, 
                    "<br><strong>GiNi: </strong>", 
                    filter(datos, anio == input$ano)$gini %>% 
                      scales::percent())
    

    pal <- colorBin(palette = "Greys", domain = datos$gini, bins=5)
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       options = providerTileOptions(noWrap = TRUE)) %>% 
      setView(lng = -56.04, lat = -32.6, zoom = 6) %>% 
      addPolygons(data=deptos, weight = 2, 
      fillColor = ~pal(giniano),
      fillOpacity=1,
      popup= popup,
      highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE))
          })
}

shinyApp(ui = ui, server = server)
