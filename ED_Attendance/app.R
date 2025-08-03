library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(stringr)
library(readr)

# Load and preprocess data
data <- read_csv("attendance_at_emd.csv") %>%
  mutate(
    ParsedDate = dmy(str_extract(Date, "\\d{2}/\\d{2}/\\d{2}")),
    Weekday = wday(ParsedDate, label = TRUE, abbr = FALSE),
    Month = month(ParsedDate, label = TRUE)
  )

# UI
ui <- fluidPage(
  titlePanel("ED Attendance Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("hospital", "Select Hospital:",
                  choices = c("AH", "CGH", "KTPH", "NTFGH", "NUH(A)", "SGH", "SKH", "TTSH", "WH"),
                  selected = "CGH"),
      
      dateRangeInput("dateRange", "Select Date Range:",
                     start = min(data$ParsedDate),
                     end = max(data$ParsedDate),
                     min = min(data$ParsedDate),
                     max = max(data$ParsedDate)),
      
      radioButtons("seasonal_type", "Seasonality View:",
                   choices = c("Day of Week" = "dow", "Month" = "month"),
                   selected = "dow")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Time Series", plotOutput("tsPlot")),
        tabPanel("Seasonality", plotOutput("seasonPlot"))
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  filteredData <- reactive({
    data %>%
      filter(
        ParsedDate >= input$dateRange[1],
        ParsedDate <= input$dateRange[2]
      ) %>%
      select(ParsedDate, Weekday, Month, !!sym(input$hospital)) %>%
      rename(Count = !!sym(input$hospital))
  })
  
  output$tsPlot <- renderPlot({
    ggplot(filteredData(), aes(x = ParsedDate, y = Count)) +
      geom_line(color = "steelblue") +
      labs(title = paste("Daily ED Attendance -", input$hospital),
           x = "Date", y = "Attendance") +
      theme_minimal()
  })
  
  output$seasonPlot <- renderPlot({
    df <- filteredData()
    
    if (input$seasonal_type == "dow") {
      df %>%
        group_by(Weekday) %>%
        summarise(MeanAttendance = mean(Count, na.rm = TRUE)) %>%
        ggplot(aes(x = Weekday, y = MeanAttendance)) +
        geom_col(fill = "tomato") +
        labs(title = paste("Average Attendance by Day of Week -", input$hospital),
             x = "Day", y = "Average Attendance") +
        theme_minimal()
    } else {
      df %>%
        group_by(Month) %>%
        summarise(MeanAttendance = mean(Count, na.rm = TRUE)) %>%
        ggplot(aes(x = Month, y = MeanAttendance)) +
        geom_col(fill = "darkorange") +
        labs(title = paste("Average Attendance by Month -", input$hospital),
             x = "Month", y = "Average Attendance") +
        theme_minimal()
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)
