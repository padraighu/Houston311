library(shiny)
library(geojsonio)
library(leaflet)

function(input, output, session) {
  load("geodata.RData")
  
  output$mymap <- renderLeaflet({
    leaflet(houston) %>% 
      setView(-95.3698, 29.7604, 10) %>%
      addTiles() %>% 
      addPolylines(
        data=citylimit,
        weight=2,
        opacity=1,
        color="blue"
      )
  })
  
  year <- reactive({
    input$year
  })
  
  category <- reactive({
    input$pick 
  })
  
  colorpal <- reactive({
    colorNumeric("YlOrRd", domain=selectedData())
  })
  
  selectedData <- reactive({
    year <- sprintf("X%d", year())
    category <- switch(
      category(),
      stray="n_stray", 
      comb="n_com",
      bite="n_bite",
      total="n_total"
    )
    #print(sprintf("year: %s, category: %s", year, category))
    varName <- paste(year, category, sep="")
    print(varName)
    houston[[varName]]
  })
  
  observe({
    dat <- selectedData()
    pal <- colorpal()
    labels <- sprintf("<strong>Zipcode: %d</strong><br><strong>Count: %d</strong>", houston$ZIP_CODE, dat) %>% lapply(htmltools::HTML)
    
    leafletProxy("mymap", data=houston) %>% 
      clearShapes() %>% 
      addPolygons(
        fillColor = ~pal(dat),
        weight = 1,
        opacity = 1,
        color = "black",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 2,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      ) %>% 
      addPolylines(
        data=citylimit,
        weight=2,
        opacity=1,
        color="blue"
      ) 
  })
  
  observe({
    proxy <- leafletProxy("mymap", data=houston) 
    pal <- colorpal()
    dat <- selectedData()
    title <- switch(
      category(),
      stray="311 calls about stray animals", 
      comb="311 calls about sick, injured or dead animals",
      bite="311 calls about animal bites",
      total="Total 311 calls"
    )
    proxy %>% 
      clearControls() %>% 
      addLegend(pal=pal, values=~dat, opacity=0.7, title=title, position="bottomright") 
  })
}

