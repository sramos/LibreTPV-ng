# Configuration for spreadsheet_on_rails gem
# This initializer sets up the spreadsheet gem for Rails

# Ensure the spreadsheet gem is properly loaded
require 'spreadsheet'

# Configure the default format for XLS files
Spreadsheet.client_encoding = 'UTF-8'
