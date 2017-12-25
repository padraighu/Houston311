library(leaflet)
library(shiny)

pageWithSidebar(
  headerPanel("Houston animal-related 311 calls"),
  sidebarPanel(
    radioButtons("pick", "Select a call category: ",
                 c("Stray"="stray", "Sick, injured or dead"="comb", "Bite"="bite", "Total"="total")),
    sliderInput(
      "year",
      "Select a year:",
    value=2012,
      min=2012, 
      max=2016
    )
  ),
  mainPanel(
    leafletOutput("mymap")
    )
)