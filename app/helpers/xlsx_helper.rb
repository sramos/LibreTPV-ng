# Methods added to this helper will be available to all templates in the application.
module XlsxHelper
  include ListsHelper

  #--
  # METODOS PARA SALIDAS XLS
  #--

  def xlsx_index workbook, attrs
    s = workbook.styles
    style_title  = s.add_style b: true, sz: 16, alignment: { horizontal: :left}
    style_header = s.add_style bg_color: 'DD', b: true, alignment: { horizontal: :center }

    attrs[:title] ||= attrs[:type]
    attrs[:sheet_name] ||= attrs[:title] || attrs[:type]
    fields = attrs[:type].is_a?(Array) ? attrs[:type] : index_fields(attrs[:type])

    workbook.add_worksheet(name: attrs[:sheet_name]) do |sheet|
      # Header
      sheet.add_row [attrs[:title]], style: style_title
      # Filter
      filters = xlsx_filter_row(attrs[:filter_scope])
      sheet.add_row [filters] if filters.present?
      # Fields
      sheet.add_row fields.collect{|field| field[0]}, style: style_header

      # Data
      attrs[:objects].each do |object|
        sheet.add_row fields.collect{|field| index_field_value(object, field[1])}
      end
    end
  end
  
  def xlsx_filter_row filter_scope
    output = nil
    if filter_scope && session[filter_scope] && session[filter_scope]['value'].present?
      output  = "Filtrado por #{session[filter_scope]['type'].capitalize} " +
                (session[filter_scope]['condition'] ? session[filter_scope]['condition'] : '>>') +
                ' ' + session[filter_scope]['value']
    end
    return output
  end
end
