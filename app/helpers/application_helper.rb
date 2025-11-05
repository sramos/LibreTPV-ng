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
    output += link_to( icono('Download', title: 'Exportar a XLS'), request.parameters.merge({format: :xls, format_xls_count: (@format_xls.to_i+1)}) ) if @format_xls
    #output += modal icono('Plus', title: 'Nuevo'), attrs[:url], attrs[:title] || 'Nuevo' if attrs[:url]
    
    output += link_to( icono('Plus', title: attrs[:title]||'Añadir nuevo'),
                       attrs[:url] || '#',
                       data: { turbo_method: :get, turbo_frame: "#{object_type}_new"},
                       class: 'link-edit') if attrs[:url]
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
  def index_footer objects=nil
    output = '</div>'
    output += index_paginator objects
    return output.html_safe
  end
  def index_paginator objects
    output = ''
    if objects.present?
      output  = "<div class='listadofila' id='paginado'>" + (paginate(objects, class: "listado_campo_2") || " ")
      output += "<div class='listado_derecha'> "+ index_pagination_info(objects)  + "</div>"
      output += "<div class='linea'></div></div>"
    end
    return output
  end
  def index_pagination_info objects
    if objects.total_pages < 2
      case objects.size
      when 0; "<b>" + "No tiene elementos" + "</b>"
      when 1; "<b>" + "Mostrando 1 elemento" + "</b>"
      else;   "<b>" + "Mostrando todos los elementos: " + (objects.size).to_s + "</b>"
      end
    else
      start_item = (objects.current_page - 1) * session[:per_page].to_i
      end_item = start_item + objects.length
      
      "Mostrando elementos <b>#{start_item + 1} - #{end_item}</b> de <b> #{objects.total_count}</b> en total"
    end
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
  # Generic beginning of a form, wrapping form_with and yielding the builder
  def form_beginning attrs={}
    attrs[:model] ||= '#'
    attrs[:turbo_frame] ||= '#'
    attrs[:html_class] ||= 'form-box'
    close_script = "this.closest('turbo-frame').innerHTML = '<div class=\\'object-container\\'></div>'; return false;"
    output  = '<div class="caja_completa">'
    output += '<div class="linea"><div class="elemento_derecha">' 
    output += link_to icono('Cancel', title: 'Cancelar'), "#", onclick: close_script
    output += '</div></div>'
    output += form_with model: attrs[:model], local: false,
                        data: { turbo_frame: attrs[:turbo_frame] }, html_class: attrs[:html_class] 
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
  def form_end attrs={}
    attrs[:send_label] ||= 'Guardar'
    attrs[:cancel_label] ||= 'Cancelar'
    output  = '<div class="linea elemento_derecha actions">'
    output += submit_tag attrs[:send_label]
    output += '</div>'
    output += '</form>'
    output += '</div><!--- Caja completa --->'
    return output.html_safe
  end

  # Other helpers
  def message msg
    return ('<div class="message">' + msg + '</div>').html_safe
  end
end
