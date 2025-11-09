# GLUE Shiny Web Application
# User Interface for Generalized Likelihood Uncertainty Estimation

# Check if required packages are installed
required_packages <- c("shiny", "shinydashboard", "shinyjs", "parallel")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse=", "), "\n")
  install.packages(missing_packages, repos = "http://cran.us.r-project.org")
}

library(shiny)
library(shinydashboard)
library(shinyjs)
library(parallel)

# Try to load future for async execution, but don't require it
if(require("future", quietly = TRUE)) {
  has_future <- TRUE
} else {
  has_future <- FALSE
  cat("Note: 'future' package not installed. GLUE will run synchronously.\n")
}

# UI Definition
ui <- dashboardPage(
  dashboardHeader(title = "GLUE - Parameter Estimation"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Configuration", tabName = "config", icon = icon("cog")),
      menuItem("Run GLUE", tabName = "run", icon = icon("play")),
      menuItem("Results", tabName = "results", icon = icon("chart-line")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$style(HTML("
        .content-wrapper {
          background-color: #f4f4f4;
        }
        .box {
          border-radius: 5px;
        }
      "))
    ),
    
    tabItems(
      # Configuration Tab
      tabItem(tabName = "config",
        fluidRow(
          box(
            title = "Directory Configuration", status = "primary", solidHeader = TRUE,
            width = 12, collapsible = TRUE,
            fluidRow(
              column(6,
                h4("GLUE Directory"),
                verbatimTextOutput("glue_dir", placeholder = TRUE),
                actionButton("browse_glue", "Browse", class = "btn-primary"),
                br(), br(),
                h4("DSSAT Directory"),
                verbatimTextOutput("dssat_dir", placeholder = TRUE),
                actionButton("browse_dssat", "Browse", class = "btn-primary"),
                br(), br(),
                h4("Output Directory"),
                verbatimTextOutput("output_dir", placeholder = TRUE),
                actionButton("browse_output", "Browse", class = "btn-primary")
              ),
              column(6,
                h4("Genotype Directory"),
                verbatimTextOutput("genotype_dir", placeholder = TRUE),
                actionButton("browse_genotype", "Browse", class = "btn-primary"),
                br(), br(),
                h4("Working Directory"),
                verbatimTextOutput("work_dir", placeholder = TRUE),
                p("Current working directory where GLUE will run")
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Model Configuration", status = "info", solidHeader = TRUE,
            width = 12, collapsible = TRUE,
            fluidRow(
              column(6,
                textInput("cultivar_batch_file", "Cultivar Batch File", 
                         value = "", placeholder = "e.g., NEWTON.WHC"),
                selectInput("model_id", "Model ID",
                           choices = c("CSCRP048", "MZCER048", "RICER048", "WHCER048"),
                           selected = "CSCRP048"),
                selectInput("glue_flag", "GLUE Flag",
                           choices = list(
                             "Both Phenology and Growth" = 1,
                             "Phenology Only" = 2,
                             "Growth Only" = 3
                           ),
                           selected = 2)
              ),
              column(6,
                numericInput("num_runs", "Number of Model Runs", 
                           value = 1000, min = 1, max = 100000),
                numericInput("cores", "Number of CPU Cores", 
                           value = max(1, parallel::detectCores() - 1), 
                           min = 1, max = parallel::detectCores()),
                selectInput("ecotype_calibration", "Ecotype Calibration",
                           choices = list("No" = "N", "Yes" = "Y"),
                           selected = "N"),
                p(strong("Available Cores:"), textOutput("available_cores", inline = TRUE))
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Actions", status = "success", solidHeader = TRUE,
            width = 12,
            actionButton("save_config", "Save Configuration", 
                        class = "btn-success", icon = icon("save")),
            actionButton("load_config", "Load Configuration", 
                        class = "btn-info", icon = icon("folder-open")),
            br(), br(),
            verbatimTextOutput("config_status")
          )
        )
      ),
      
      # Run Tab
      tabItem(tabName = "run",
        fluidRow(
          box(
            title = "GLUE Execution", status = "warning", solidHeader = TRUE,
            width = 12,
            p("Make sure you have configured all settings before running GLUE."),
            br(),
            actionButton("run_glue", "Run GLUE", 
                        class = "btn-lg btn-success", 
                        icon = icon("play-circle")),
            actionButton("stop_glue", "Stop", 
                        class = "btn-danger", 
                        icon = icon("stop")),
            br(), br(),
            h4("Progress"),
            verbatimTextOutput("run_status"),
            br(),
            h4("Log Output"),
            verbatimTextOutput("log_output")
          )
        )
      ),
      
      # Results Tab
      tabItem(tabName = "results",
        fluidRow(
          box(
            title = "Results Viewer", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Output Files"),
            verbatimTextOutput("output_files"),
            br(),
            h4("Warnings"),
            verbatimTextOutput("warnings"),
            br(),
            h4("Model Run Indicator"),
            verbatimTextOutput("run_indicator")
          )
        )
      ),
      
      # About Tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About GLUE", status = "info", solidHeader = TRUE,
            width = 12,
            h3("Generalized Likelihood Uncertainty Estimation"),
            p("GLUE is a Bayesian estimation approach that uses Monte Carlo sampling 
              from prior distributions of coefficients and a Gaussian likelihood function 
              to determine the best coefficients based on observed data."),
            br(),
            h4("Features:"),
            tags$ul(
              tags$li("Parallel processing for faster calibration"),
              tags$li("Estimates genotype-specific coefficients for DSSAT crop models"),
              tags$li("Supports phenology and/or growth coefficient calibration"),
              tags$li("User-friendly web interface")
            ),
            br(),
            h4("Citation:"),
            p("Ferreira, T. B., V. Shelia, C. Porter, P. M. Cadena, M. S. Cortasa, 
              M. S. Khan, W. Pavan, G. Hoogenboom. 2024. Enhancing crop model parameter 
              estimation across computing environments: Utilizing the GLUE method and 
              parallel computing for determining genetic coefficients. Computers and 
              Electronics in Agriculture, 227, 109513."),
            br(),
            p(strong("Version:"), "2.0.0.0"),
            p(strong("License:"), "BSD-3-Clause")
          )
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Get current working directory
  work_dir <- getwd()
  
  # Reactive values
  values <- reactiveValues(
    glue_dir = work_dir,
    dssat_dir = "",
    output_dir = "",
    genotype_dir = "",
    config_saved = FALSE,
    glue_running = FALSE
  )
  
  # Display available cores
  output$available_cores <- renderText({
    parallel::detectCores()
  })
  
  # Display current working directory
  output$work_dir <- renderText({
    work_dir
  })
  
  # Directory browsing (using text inputs for cross-platform compatibility)
  output$glue_dir <- renderText({
    values$glue_dir
  })
  
  output$dssat_dir <- renderText({
    if(values$dssat_dir == "") "Not set" else values$dssat_dir
  })
  
  output$output_dir <- renderText({
    if(values$output_dir == "") "Not set" else values$output_dir
  })
  
  output$genotype_dir <- renderText({
    if(values$genotype_dir == "") "Not set" else values$genotype_dir
  })
  
  # Directory selection buttons (cross-platform)
  observeEvent(input$browse_glue, {
    if(.Platform$OS.type == "windows" && exists("choose.dir", where = "package:utils")) {
      dir <- utils::choose.dir(default = values$glue_dir, caption = "Select GLUE Directory")
      if(!is.na(dir)) values$glue_dir <- dir
    } else {
      # For Unix/Mac, use text input dialog
      showModal(modalDialog(
        title = "Enter GLUE Directory Path",
        textInput("glue_dir_input", "Path:", value = values$glue_dir),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("set_glue_dir", "OK")
        )
      ))
    }
  })
  
  observeEvent(input$set_glue_dir, {
    if(dir.exists(input$glue_dir_input)) {
      values$glue_dir <- input$glue_dir_input
      removeModal()
    }
  })
  
  observeEvent(input$browse_dssat, {
    if(.Platform$OS.type == "windows" && exists("choose.dir", where = "package:utils")) {
      dir <- utils::choose.dir(caption = "Select DSSAT Directory")
      if(!is.na(dir)) values$dssat_dir <- dir
    } else {
      showModal(modalDialog(
        title = "Enter DSSAT Directory Path",
        textInput("dssat_dir_input", "Path:", value = values$dssat_dir),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("set_dssat_dir", "OK")
        )
      ))
    }
  })
  
  observeEvent(input$set_dssat_dir, {
    if(dir.exists(input$dssat_dir_input)) {
      values$dssat_dir <- input$dssat_dir_input
      removeModal()
    }
  })
  
  observeEvent(input$browse_output, {
    if(.Platform$OS.type == "windows" && exists("choose.dir", where = "package:utils")) {
      dir <- utils::choose.dir(caption = "Select Output Directory")
      if(!is.na(dir)) values$output_dir <- dir
    } else {
      showModal(modalDialog(
        title = "Enter Output Directory Path",
        textInput("output_dir_input", "Path:", value = values$output_dir),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("set_output_dir", "OK")
        )
      ))
    }
  })
  
  observeEvent(input$set_output_dir, {
    if(dir.exists(input$output_dir_input)) {
      values$output_dir <- input$output_dir_input
      removeModal()
    }
  })
  
  observeEvent(input$browse_genotype, {
    if(.Platform$OS.type == "windows" && exists("choose.dir", where = "package:utils")) {
      dir <- utils::choose.dir(caption = "Select Genotype Directory")
      if(!is.na(dir)) values$genotype_dir <- dir
    } else {
      showModal(modalDialog(
        title = "Enter Genotype Directory Path",
        textInput("genotype_dir_input", "Path:", value = values$genotype_dir),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("set_genotype_dir", "OK")
        )
      ))
    }
  })
  
  observeEvent(input$set_genotype_dir, {
    if(dir.exists(input$genotype_dir_input)) {
      values$genotype_dir <- input$genotype_dir_input
      removeModal()
    }
  })
  
  # Save configuration
  observeEvent(input$save_config, {
    # Validate inputs
    if(input$cultivar_batch_file == "") {
      output$config_status <- renderText("Error: Cultivar Batch File is required")
      return()
    }
    
    if(values$dssat_dir == "" || values$output_dir == "" || values$genotype_dir == "") {
      output$config_status <- renderText("Error: All directories must be set")
      return()
    }
    
    # Create SimulationControl.csv
    config_data <- data.frame(
      Variable = c("CultivarBatchFile", "ModelID", "EcotypeCalibration", 
                   "GLUED", "OutputD", "DSSATD", "GLUEFlag", 
                   "NumberOfModelRun", "Cores", "GenotypeD"),
      Value = c(input$cultivar_batch_file, input$model_id, input$ecotype_calibration,
                values$glue_dir, values$output_dir, values$dssat_dir, 
                as.character(input$glue_flag), as.character(input$num_runs),
                as.character(input$cores), values$genotype_dir)
    )
    
    # Save to working directory
    write.csv(config_data, file.path(work_dir, "SimulationControl.csv"), 
              row.names = FALSE)
    
    values$config_saved <- TRUE
    output$config_status <- renderText({
      paste("Configuration saved successfully to:", 
            file.path(work_dir, "SimulationControl.csv"))
    })
  })
  
  # Load configuration
  observeEvent(input$load_config, {
    config_file <- file.path(work_dir, "SimulationControl.csv")
    if(file.exists(config_file)) {
      config_data <- read.csv(config_file)
      
      # Update UI values
      updateTextInput(session, "cultivar_batch_file", 
                     value = config_data[config_data$Variable == "CultivarBatchFile", "Value"])
      updateSelectInput(session, "model_id", 
                       selected = config_data[config_data$Variable == "ModelID", "Value"])
      updateSelectInput(session, "glue_flag", 
                       selected = as.numeric(config_data[config_data$Variable == "GLUEFlag", "Value"]))
      updateNumericInput(session, "num_runs", 
                        value = as.numeric(config_data[config_data$Variable == "NumberOfModelRun", "Value"]))
      updateNumericInput(session, "cores", 
                        value = as.numeric(config_data[config_data$Variable == "Cores", "Value"]))
      updateSelectInput(session, "ecotype_calibration", 
                       selected = config_data[config_data$Variable == "EcotypeCalibration", "Value"])
      
      values$glue_dir <- config_data[config_data$Variable == "GLUED", "Value"]
      values$dssat_dir <- config_data[config_data$Variable == "DSSATD", "Value"]
      values$output_dir <- config_data[config_data$Variable == "OutputD", "Value"]
      values$genotype_dir <- config_data[config_data$Variable == "GenotypeD", "Value"]
      
      output$config_status <- renderText("Configuration loaded successfully")
    } else {
      output$config_status <- renderText("Configuration file not found")
    }
  })
  
  # Run GLUE
  observeEvent(input$run_glue, {
    config_file <- file.path(work_dir, "SimulationControl.csv")
    if(!file.exists(config_file)) {
      output$run_status <- renderText("Configuration file not found. Please save configuration first.")
      return()
    }
    
    # Validate GLUE directory
    glue_script <- file.path(values$glue_dir, "GLUE.r")
    if(!file.exists(glue_script)) {
      output$run_status <- renderText(paste("GLUE.r not found at:", glue_script))
      return()
    }
    
    values$glue_running <- TRUE
    disable("run_glue")
    enable("stop_glue")
    output$run_status <- renderText("GLUE is running... Please wait. This may take a while.")
    
    # Run GLUE (synchronously for now - can be improved with future package)
    old_wd <- getwd()
    tryCatch({
      # Change to GLUE directory temporarily
      setwd(values$glue_dir)
      
      # Capture output
      log_file <- file.path(values$output_dir, "GLUE_UI_Log.txt")
      sink(file = log_file, append = TRUE)
      source("GLUE.r")
      sink()
      
      setwd(old_wd)
      output$run_status <- renderText("GLUE completed successfully! Check the Results tab for output files.")
      values$glue_running <- FALSE
      enable("run_glue")
      disable("stop_glue")
    }, error = function(e) {
      # Restore working directory on error
      try(setwd(old_wd), silent = TRUE)
      sink()  # Close any open sink
      output$run_status <- renderText(paste("Error:", e$message))
      values$glue_running <- FALSE
      enable("run_glue")
      disable("stop_glue")
    })
  })
  
  # Stop GLUE
  observeEvent(input$stop_glue, {
    values$glue_running <- FALSE
    output$run_status <- renderText("GLUE execution stopped")
  })
  
  # Display results
  output$output_files <- renderText({
    if(values$output_dir != "" && dir.exists(values$output_dir)) {
      files <- list.files(values$output_dir, full.names = FALSE)
      if(length(files) > 0) {
        paste(files, collapse = "\n")
      } else {
        "No output files found"
      }
    } else {
      "Output directory not set or does not exist"
    }
  })
  
  output$warnings <- renderText({
    if(values$output_dir != "" && dir.exists(values$output_dir)) {
      warning_file <- file.path(values$output_dir, "GlueWarning.txt")
      if(file.exists(warning_file)) {
        paste(readLines(warning_file), collapse = "\n")
      } else {
        "No warnings found"
      }
    } else {
      "Output directory not set"
    }
  })
  
  output$run_indicator <- renderText({
    if(values$output_dir != "" && dir.exists(values$output_dir)) {
      indicator_file <- file.path(values$output_dir, "ModelRunIndicator.txt")
      if(file.exists(indicator_file)) {
        paste(readLines(indicator_file), collapse = "\n")
      } else {
        "No run indicator found"
      }
    } else {
      "Output directory not set"
    }
  })
  
  output$log_output <- renderText({
    "Log output will appear here when GLUE is running..."
  })
}

# Run the application
shinyApp(ui = ui, server = server)

