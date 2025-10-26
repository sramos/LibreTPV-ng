# Register custom MIME types
# This file registers additional MIME types that are not included by default in Rails

# Register XLS (Excel 97-2003) MIME type
Mime::Type.register "application/vnd.ms-excel", :xls

# You can add more MIME types here as needed
# Example:
# Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
