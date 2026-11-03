library(shiny)

specimens <- read.csv("data/example.csv", stringsAsFactors = FALSE)
specimens$DateCollected <- as.Date(specimens$DateCollected)
specimen_types <- c("CSF", "Blood", "Tissue")
date_limits <- range(specimens$DateCollected)

period_start <- function(dates, binning) {
  month <- as.integer(format(dates, "%m"))
  month <- switch(
    binning,
    Month = month,
    Quarter = ((month - 1L) %/% 3L) * 3L + 1L,
    Year = rep(1L, length(dates))
  )
  as.Date(sprintf("%s-%02d-01", format(dates, "%Y"), month))
}

summary_card <- function(label, count) {
  column(3, wellPanel(h4(label), h2(format(count, big.mark = ","))))
}

ui <- fluidPage(
  titlePanel("Specimen inventory"),
  p("All specimens in the inventory"),
  fluidRow(
    summary_card("Total specimens", nrow(specimens)),
    lapply(specimen_types, function(type) {
      summary_card(type, sum(specimens$Type == type))
    })
  ),
  sidebarLayout(
    sidebarPanel(
      h3("Chart filters"),
      selectInput(
        "binning", "Group by", c("Month", "Quarter", "Year"),
        selected = "Month"
      ),
      checkboxGroupInput(
        "specimen_types", "Specimen types", specimen_types,
        selected = specimen_types
      ),
      dateRangeInput(
        "date_range", "Collection date range",
        start = date_limits[1], end = date_limits[2],
        min = date_limits[1], max = date_limits[2],
        format = "yyyy-mm-dd"
      )
    ),
    mainPanel(
      h3("Samples collected"),
      textOutput("sample_count"),
      plotOutput("collection_chart", height = "450px")
    )
  )
)

server <- function(input, output, session) {
  filtered_specimens <- reactive({
    dates <- input$date_range
    validate(need(
      length(dates) == 2L && !anyNA(dates),
      "Select both a start date and an end date."
    ))
    validate(need(dates[1] <= dates[2], "The start date must precede the end date."))

    specimens[
      specimens$Type %in% input$specimen_types &
        specimens$DateCollected >= dates[1] &
        specimens$DateCollected <= dates[2],
      , drop = FALSE
    ]
  })

  collection_counts <- reactive({
    filtered <- filtered_specimens()
    binning <- req(input$binning)
    dates <- input$date_range
    periods <- seq(
      period_start(dates[1], binning),
      period_start(dates[2], binning),
      by = switch(binning, Month = "month", Quarter = "3 months", Year = "year")
    )
    labels <- switch(
      binning,
      Month = format(periods, "%Y-%m"),
      Quarter = paste0(
        format(periods, "%Y"), " Q",
        (as.integer(format(periods, "%m")) - 1L) %/% 3L + 1L
      ),
      Year = format(periods, "%Y")
    )

    data.frame(
      Period = periods,
      Label = labels,
      Specimens = tabulate(
        match(period_start(filtered$DateCollected, binning), periods),
        nbins = length(periods)
      )
    )
  })

  output$sample_count <- renderText({
    sprintf(
      "Showing %s of %s specimens",
      format(nrow(filtered_specimens()), big.mark = ","),
      format(nrow(specimens), big.mark = ",")
    )
  })

  output$collection_chart <- renderPlot({
    counts <- collection_counts()
    validate(need(sum(counts$Specimens) > 0, "No specimens match the selected filters."))

    par(mar = c(7, 4, 1, 1))
    barplot(
      counts$Specimens,
      names.arg = counts$Label,
      col = "#2c7fb8",
      border = NA,
      las = 2,
      cex.names = if (nrow(counts) > 20) 0.7 else 0.9,
      ylab = "Specimens"
    )
    mtext("Collection period", side = 1, line = 5.5)
  }, res = 96)
}

shinyApp(ui, server)
