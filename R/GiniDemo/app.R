#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)
library(shinyWidgets)
load("gini_anio_dpto.RData")


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Gini Demo"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            pickerInput(inputId = "dptos",
                        label = span(icon("map-marker-alt"), "Departamentos:"),
                        choices = sort(unique(gini_anio_dpto$nomdpto)),
                        selected = sort(unique(gini_anio_dpto$nomdpto)),
                        options = list(
                          `deselect-all-text` = "Ninguno",
                          `select-all-text` = "Todos",
                          `actions-box` = TRUE,
                          `live-search` = TRUE,
                          size = 19),
                        multiple = TRUE),
            tags$a("(Ver reporte...)", href = "gini.html")
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("tendencias")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$tendencias <- renderPlot({
        # generate bins based on input$bins from ui.R
      gini_anio_dpto %>% 
        filter(nomdpto %in% input$dptos) %>% 
        ggplot() +
        aes(anio, Gini, col = nomdpto) +
        geom_line() + 
        geom_text(data = filter(gini_anio_dpto, 
                                anio %in% c(2011, 2018),
                                nomdpto %in% input$dptos), 
                  aes(label = nomdpto), 
                  hjust = "outward") +
        scale_y_continuous(labels = scales::percent) +
        scale_x_continuous(limits = c(2009, 2020), breaks = 2011:2018, minor_breaks = NULL) +
        theme(legend.position="none") +
        xlab("Año") + ylab("Gini (%)")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
