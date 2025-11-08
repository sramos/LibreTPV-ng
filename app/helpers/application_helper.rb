module ApplicationHelper

  # Index helpers
  def index_header object_type, attrs={}
    # Sacamos los campos a mostrar bien vengan como array (posicion global) o como tipo
    fields = object_type.is_a?(Array) ? object_type : index_fields(object_type)
    output = ''
    # Dibujamos el bloque de nuevos objetos
    output += index_new_objects_header(object_type, attrs) if attrs[:new_url]
    # Dibujamos la cabecera del listado
    output += "<div class='listado'><div class='listadocabecera'>"
    for field in fields
      output += "<div class='listado_campo_#{field[2]}' id='listado_campo_etiqueta_#{field[1]}'>" + field[0] + "</div>"
    end
    output += "<div class='listado_derecha'>"
    output += link_to( icon('download', title: 'Exportar a XLS'), request.parameters.merge({format: :xls, format_xls_count: (@format_xls.to_i+1)}) ) if @format_xls    
    output += link_to( icon('plus', title: attrs[:title]||'Añadir nuevo'),
                       attrs[:new_url] || '#',
                       data: { turbo_method: :get, turbo_frame: 'modal' },
                       class: 'link-edit') if attrs[:new_url]
    output += "</div></div>"
    return output.html_safe
  end
  def index_new_objects_header object_type, attrs={}
    output = ''
    output  = "<div id='new_#{object_type}_section' style='display:none'>"
    output += index_header object_type
    output += turbo_frame_tag("turbo_stream_new_#{object_type}"){"<div id='new_#{object_type}_tag'></div>".html_safe}
    output += index_footer
    output += message ('Los nuevos elementos añadidos se incorporarán al listado principal (abajo) cuando se vuelva a ' +
                        link_to('refrescar la página', attrs[:refresh_url])) if attrs[:refresh_url]
    output += '<div class="linea"></div></div>'
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
      value = 'No' if value.class.name == 'FalseClass' && field[1] != 'valor_defecto'
      value = value.strftime("%d/%m/%Y") if value.class.name == 'Date'
      value = sprintf("%.2f", value) if value.class.name == 'Float'
      value = '&nbsp;' if value.blank?
      output += "<div class='#{html_class}' id='#{html_id}' title='#{value}'>" + value + '</div>'
    end
    return output.html_safe
  end
  def index_field_value object, field
    value = field.blank? ? nil :object
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
    data_attrs = { turbo_method: :get, turbo_frame: 'modal' }
    data_attrs[:turbo_frame] = attrs[:turbo_frame] if attrs[:turbo_frame]
    
    link_to(attrs[:url] || '#',
                     data: data_attrs,
                     class: 'link-edit') do
      attrs[:icon] || icon('pen', title: attrs[:title]||'Editar')
    end
  end

  def object_destroy attrs={}
    link_to(attrs[:url] || '#',
                     data: { 
                       turbo_method: :delete, 
                       turbo_confirm: attrs[:confirmation] || '¿Está seguro?'
                     },
                     class: 'link-delete') do
      attrs[:icon] || icon('trash', title: attrs[:title]||'Borrar')
    end
  end

  # Icons using font awesome
  def icon fa_name, attrs={}
    # FA style prefix. Defaults to 'fa' (compatible). Allow overriding with :fa => 'fas'/'far'/'fab'.
    fa_prefix = (attrs[:fa] || 'fa').to_s
    # Optional size like 'lg', '2x', etc.
    size_class = attrs[:size] ? "fa-#{attrs[:size]}" : nil
    classes = [fa_prefix, "fa-#{fa_name}"]
    classes << size_class if size_class
    classes << attrs[:class] if attrs[:class]
    content_tag(:i, '', class: classes.compact.join(' '), title: attrs[:title], aria: { hidden: true })
  end

  # Form helpers
  # Generic beginning of a form, wrapping form_with and yielding the builder
  def form_beginning attrs={}
    attrs[:model] ||= '#'
    attrs[:header] ||= 'Formulario'
    attrs[:turbo_frame] ||= '#'
    attrs[:html_class] ||= 'form-box'
    output  = '<div class="modal-overlay" onclick="document.getElementById(\'modal\').innerHTML=\'\'"></div>'
    output += '<div class="modal-panel" onclick="event.stopPropagation()">'
    output += '<div class="modal-header">'
    output += '<h3>' + attrs[:header]+ '</h3>'
    output += link_to '✕', '#', onclick: "document.getElementById('modal').innerHTML=''; return false;", class: 'modal-close'
    output += '</div>'
    output += '<div class="modal-body"><div class="linea"></div>' 
    output += form_with model: attrs[:model], local: false,
                        data: { turbo_frame: attrs[:turbo_frame] }, html_class: attrs[:html_class] 
    return turbo_frame_tag('modal') { output.html_safe }
  end
  def form_errors object
    output = ''
    if object.errors.any?
      output += '<div id="error_explanation"><h2>'
      output += pluralize(object.errors.count, 'error') + ' impiden guardar el objeto:</h2><ul>'
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
    output  = '<br><div class="linea elemento_derecha actions">'
    output += submit_tag attrs[:send_label]
    output += '</div></form>'
    output += '<div class="linea"></div>'
    output += '</div></div><!--- Caja completa --->'
    return output.html_safe
  end

  # Other helpers
  def message msg
    return ('<div class="message">' + msg + '</div>').html_safe
  end

  def update_object_turbo_stream container_dom_id:, stream_action: :replace, stream_partial: 'item', stream_locals: {}, highlight_dom_id: nil, show_section_id: nil
    highlight_dom_id ||= container_dom_id
    script = "(function(){\n"+
             (show_section_id ? "  var s=document.getElementById('#{show_section_id}'); if(s){ s.style.display='block'; }\n" : '') +
             "  var el=document.getElementById('#{highlight_dom_id}');\n"+
             "  if(el){\n"+
             "    try { el.classList.add('flash-highlight'); } catch(e){}\n"+
             "    el.scrollIntoView({behavior:'smooth',block:'center'});\n"+
             "    var prevBg = el.style.backgroundColor; var prevTransition = el.style.transition;\n"+
             "    el.style.transition = 'background-color 0.6s ease'; el.style.backgroundColor = '#fff3cd';\n"+
             "    setTimeout(function(){ el.style.backgroundColor = prevBg || ''; el.style.transition = prevTransition || ''; try { el.classList.remove('flash-highlight'); } catch(e){} }, 1600);\n"+
             "  }\n"+
             "  var m=document.getElementById('modal'); if(m){ setTimeout(function(){ m.innerHTML='' }, 300); }\n"+
             "})();"
    streams = []
    case stream_action.to_sym
    when :after
      streams << turbo_stream.after(container_dom_id, partial: stream_partial, locals: stream_locals.merge({highlight: true}))
    when :replace
      streams << turbo_stream.replace(container_dom_id, partial: stream_partial, locals: stream_locals.merge({highlight: true}))
    else
      streams << turbo_stream.update(container_dom_id, partial: stream_partial, locals: stream_locals.merge({highlight: true}))
    end
    streams << turbo_stream.update('modal', javascript_tag(script))
    streams
  end
end
