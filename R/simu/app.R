library(shiny)
library(shinyWidgets)

nombres_input <- c(
  "partida_agui",
  "partida_salvac",
  "param_x"
  )

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Parámetros para el simulador"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      checkboxInput("partida_agui",
                    "Partida aguinaldo:", 
                    value = TRUE),
      checkboxInput("partida_salvac",
                    "Partida salario vacacional:", 
                    value = TRUE),
      numericInput("param_x", 
                   "Parametro X", 
                   value = 50,
                   min = 0, max = 100, step = .5)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      htmlOutput("salida_texto"),
      downloadButton("descargar", 
                     "Descargar lista (.RData)")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  lista_param <- reactive({
    out <- vector("list")
    print("lista_param")
    for (i in 1:(length(nombres_input))) {
      out[[i]] <- input[[nombres_input[i]]]
    }
    return(out)
  })
  
  output$salida_texto <- renderUI({
    out <- nombres_input
    for (i in 1:(length(lista_param()))) {
      out[i] <- paste(nombres_input[i], "=", lista_param()[[i]])
    }
    # writeLines(out, "parametros.R")
    HTML(paste(out, collapse = '<br/>'))
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste('param-simulador-', Sys.Date(), '.RData', sep='')
    },
    content = function(con) {
      objeto <- lista_param()
      save(objeto, file = con)
    }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)
