#!/bin/bash
# Launch script for GLUE Shiny UI (Unix/Mac)
# Usage: ./run_ui.sh

echo "Starting GLUE Shiny Application..."
echo "The application will open in your default web browser."
echo "Press Ctrl+C to stop the application."
echo ""

# Check if R is installed
if ! command -v Rscript &> /dev/null; then
    echo "Error: Rscript is not installed or not in PATH"
    exit 1
fi

# Check if app.R exists
if [ ! -f "app.R" ]; then
    echo "Error: app.R not found. Please run this script from the GLUE directory."
    exit 1
fi

# Run the Shiny app
Rscript run_ui.R

