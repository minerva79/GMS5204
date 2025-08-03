library(shiny)
library(sf)
library(ggplot2)
library(dplyr)
library(geosphere)
library(DT)

# Load preprocessed .rds objects
geo_subzones <- readRDS("./data/geo_subzones_clean.rds") %>% st_make_valid()
hospitals_sf <- readRDS("./data/hospitals_sf.rds") %>% st_make_valid()
fire_stations_sf <- readRDS("./data/fire_stations_sf.rds") %>% st_make_valid()

# UI
ui <- fluidPage(
  titlePanel("Singapore Subzone Proximity Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Display Options"),
      checkboxInput("show_hospitals", "Show Hospitals", TRUE),
      checkboxInput("show_firestations", "Show Fire Stations", TRUE),
      hr(),
      h4("Patient Location Input (WGS84)"),
      numericInput("lat", "Latitude", value = 1.3521),
      numericInput("lon", "Longitude", value = 103.8198),
      radioButtons("target_type", "Compute Distance To:",
                   choices = c("Hospital", "Fire Station")),
      actionButton("compute", "Compute Nearest")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Static Map", plotOutput("static_map", height = "700px")),
        tabPanel("Distance Table", DTOutput("distance_table"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  patient_sf <- reactive({
    req(input$lat, input$lon)
    st_as_sf(data.frame(lat = input$lat, lon = input$lon),
             coords = c("lon", "lat"), crs = 4326)
  })
  
  target_sf <- reactive({
    if (input$target_type == "Hospital") hospitals_sf else fire_stations_sf
  })
  
  distance_df <- eventReactive(input$compute, {
    pts <- matrix(st_coordinates(patient_sf()), ncol = 2)
    tgts <- st_coordinates(target_sf())
    
    dists <- geosphere::distHaversine(pts, tgts)
    
    target_sf() %>%
      st_drop_geometry() %>%
      mutate(
        distance_m = round(dists, 1),
        .row_id = row_number()
      ) %>%
      arrange(distance_m)
  })
  
  output$distance_table <- renderDT({
    req(distance_df())
    df <- distance_df() %>% select(-.row_id)
    min_index <- which.min(df$distance_m)
    
    datatable(df, options = list(pageLength = 10), rownames = FALSE) %>%
      formatStyle(
        columns = names(df),
        target = "row",
        backgroundColor = styleEqual(min_index, "lightgreen"),
        fontWeight = styleEqual(min_index, "bold")
      )
  })
  
  output$static_map <- renderPlot({
    req(input$compute)
    
    patient <- patient_sf()
    targets <- target_sf()
    dist_tbl <- distance_df()
    nearest_idx <- dist_tbl$.row_id[1]
    nearest <- targets[nearest_idx, ]
    nearest_label <- if (input$target_type == "Hospital") nearest$hospital_name else nearest$fire_station_name
    
    all_targets <- targets %>% 
      mutate(label = if (input$target_type == "Hospital") hospital_name else fire_station_name)
    
    ggplot() +
      geom_sf(data = geo_subzones, fill = "grey90", color = "white") +
      
      { if (input$show_hospitals) geom_sf(data = hospitals_sf, aes(color = "Hospital"), shape = 16, size = 2.5) } +
      { if (input$show_firestations) geom_sf(data = fire_stations_sf, aes(color = "Fire Station"), shape = 17, size = 2.5) } +
      
      #geom_sf_text(data = all_targets, aes(label = label), size = 3, nudge_y = 0.002, check_overlap = TRUE) +
      
      geom_sf(data = patient, aes(color = "Patient"), shape = 8, size = 4, stroke = 1.5) +
      geom_sf(data = nearest, aes(color = "Nearest"), shape = 15, size = 3.5) +
      
      scale_color_manual(
        name = "Legend",
        values = c("Patient" = "purple", "Nearest" = "darkgreen",
                   "Hospital" = "blue", "Fire Station" = "red")
      ) +
      
      labs(
        title = paste0("Nearest ", input$target_type, ": ", nearest_label),
        subtitle = paste0("Distance: ", dist_tbl$distance_m[1], " m")
      ) +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
}

shinyApp(ui, server)
