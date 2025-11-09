#!/usr/bin/env Rscript
# Launch script for GLUE Shiny UI
# Usage: Rscript run_ui.R

cat("Starting GLUE Shiny Application...\n")
cat("The application will open in your default web browser.\n")
cat("Press Ctrl+C (or Cmd+C on Mac) to stop the application.\n\n")

# Check if app.R exists
if(!file.exists("app.R")) {
  stop("app.R not found. Please run this script from the GLUE directory.")
}

# Launch the Shiny app
shiny::runApp("app.R", host = "127.0.0.1", port = 3838, launch.browser = TRUE)

