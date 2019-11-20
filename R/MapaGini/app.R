library(shiny)
library(leaflet)
library(tidyverse)
library(rgdal)
library(maptools)
library(DT)
library(formattable)

# setwd("R/MapaGini/")

# Importación de la capa vectorial con los departamentos (descargada de
# https://www.dinama.gub.uy/geoservicios):
deptos <- readOGR(dsn = ".", layer = "c004Polygon", stringsAsFactors = FALSE)
w <- which(deptos$NOMBRE == "LIMITE CONTESTADO")
deptos <- deptos[-w,]

# Esta pequeña tabla es para ordenar los nombres de los departamentos (y sus
# coeficientes Gini) de forma acorde a como están ordenados en el objeto mapa
# (ver más adelante):
nombresDeptos <- 
  deptos@data %>%
  transmute(nomdepto = as.character(NOMBRE))

# Tabla con los índices Gini por año y departamento:
datos <- read_delim(
  "gini_anio_dpto.csv",
  ";", escape_double = FALSE, 
  locale = locale(decimal_mark = ",", grouping_mark = "."), 
  trim_ws = TRUE)
names(datos) <- c("anio", "nomdepto", "gini")

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
              step = 1,
              value = 2015,
              sep = ""),
  # Leaflet map
  mainPanel(
    # Mapa:
    leafletOutput(outputId = 'map'),
    
    tags$hr(),
    
    # Tabla:
    DT::dataTableOutput("tabla"))
  )
  

server <- function(input, output) {
  
  # Filtrar los datos para quedarnos sólo con los del año seleccionado:
  datos_anio <- reactive({
    datos %>%
      filter(anio == input$ano) %>% 
      arrange(nomdepto)
    # Este objeto se usará tanto para el popup del mapa como para la tabla.
  })
  
  # Construcción del mapa:  
  output$map <- renderLeaflet({
    
    # Esto es necesario para que el orden de los gini coincida con el orden de
    # los departamentos en el mapa:
    giniano <- left_join(nombresDeptos, datos_anio()) %>%
      pull(gini)
    
    # El objeto popup es un vector character con el código HTML
    popup <- paste0("<strong>Departamento: </strong>", 
                    deptos$NOMBRE, 
                    "<br><strong>GiNi: </strong>", 
                    giniano %>% scales::percent())

    # Objeto (función) para determinar el coloreado de los deptos
    pal <- colorBin(palette = "Purples", domain = datos$gini, bins = 5)
    
    # Comandos para renderear la apariecia el mapa:
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery,
                       options = providerTileOptions(noWrap = TRUE)) %>% 
      setView(lng = -56.04, lat = -32.6, zoom = 6) %>% 
      addPolygons(
        data = deptos, 
        weight = 2, 
        fillColor = ~pal(giniano),
        fillOpacity = .5,
        popup = popup,
        highlightOptions = highlightOptions(color = "white", 
                                            weight = 2, 
                                            bringToFront = TRUE)
        )
    })
  
  # Preparar la tabla para la app:
  output$tabla <- DT::renderDataTable({
    datos_anio() %>% 
      select(-anio, Departamento = nomdepto, Gini = gini) %>% 
    DT::datatable(rownames = FALSE, options = list(lengthMenu = c(5, 10, 19), 
                                                   pageLength = 19)) %>% 
      formatPercentage('Gini', 2)
      
  })
}

shinyApp(ui = ui, server = server)
