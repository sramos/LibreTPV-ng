module ApplicationHelper

  # Index helpers
  def index_header object_type, attrs={}
    # Sacamos los campos a mostrar bien vengan como array (posicion global) o como tipo
    fields = object_type.is_a?(Array) ? object_type : index_fields(object_type)
    # Dibujamos la cabecera del listado
    output = "<div class='listado'><div class='listadocabecera'>"
    for field in fields
      output += "<div class='listado_campo_#{field[2]}' id='listado_campo_etiqueta_#{field[1]}'>" + field[0] + "</div>"
    end
    output += "<div class='listado_derecha'>"
    output += link_to( icono('Download', {title: 'Exportar a XLS'} ), request.parameters.merge({format: :xls, format_xls_count: (@format_xls.to_i+1)}) ) if @format_xls
    output += modal icono('Plus',{title: "Nuevo"}), attrs[:url], attrs[:title] || 'Nuevo' if attrs[:url]
    output += "</div></div>"
    return output.html_safe
  end
  def index_line object, object_type
    fields = object_type.is_a?(Array) ? object_type : index_fields(object_type)
    output = ''

    for field in fields 
      html_id = 'listado_campo_valor_' + field[1]
      html_class = 'listado_campo_' + field[2] 
      if object.class.name == 'Array'
        value = object[0]
      else
        value = index_field_value(object, field[1])
        html_id += "_#{object.id}"
      end
      value = value.localtime.strftime("%d/%m/%Y %H:%M:%S") if value.class.name == 'ActiveSupport::TimeWithZone'
      value = 'Sí' if value.class.name == 'TrueClass'
      value = 'No' if value.class.name == 'FalseClass' && campo != 'valor_defecto'
      value = value.strftime("%d/%m/%Y") if value.class.name == 'Date'
      value = sprintf("%.2f", value) if value.class.name == 'Float'
      output += "<div class='#{html_class}' id='#{html_id}' title='#{value||'&nbsp;'}'>" + value + '</div>'
    end
    return output.html_safe
  end
  def index_field_value object, field
    value = object
    field.split('.').each do |method|
      value = (method =~ /(\S+)\s(\S+)/ ? value.send($1,$2) : value.send(method)) if value
    end
    return value
  end
  def index_footer
    return '</div>'.html_safe
  end

  # Action buttons 
  def object_edition attrs={}
    data_attrs = { turbo_method: :get }
    data_attrs[:turbo_frame] = attrs[:turbo_frame] if attrs[:turbo_frame]
    
    link_to(attrs[:url] || '#',
                     data: data_attrs,
                     class: 'link-edit') do
      attrs[:icon] || icono('Write', title: attrs[:title]||'Editar')
    end
  end

  def object_destroy attrs={}
    link_to(attrs[:url] || '#',
                     data: { 
                       turbo_method: :delete, 
                       turbo_confirm: attrs[:confirmation] || '¿Está seguro?'
                     },
                     class: 'link-delete') do
      attrs[:icon] || icono('Trash', title: attrs[:title]||'Borrar')
    end
  end

  # Form helpers
  def form_beginning object
    # <%= form_with model: [:admin, vat], local: false, data: { turbo_frame: "vat_#{vat.id}_sub" } do |form| %>
    output += "<div class='fila'></div>"
    return output.html_safe
  end
  def form_errors object
    output = ''
    if object.errors.any?
      output += '<div id="error_explanation"><h2>'
      output += pluralize(object.errors.count, 'error') + ' prohibited this object from being saved:</h2><ul>'
      object.errors.each do |error|
        output += "<li>#{error.full_message}</li>"
      end
      output += '</ul></div>'
    end
    return output.html_safe
  end
  def form_actions form, attrs={}
    attrs[:send_label] ||= 'Guardar'
    attrs[:cancel_label] ||= 'Cancelar'
    output  = '<div class="linea actions">'
    output += form.submit attrs[:send_label] 
    output += link_to attrs[:cancel_label], "#", onclick: "this.closest('turbo-frame').innerHTML = '<div class=\\'object-container\\'></div>'; return false;"
    output += '</div>'
    return output.html_safe
  end
end
