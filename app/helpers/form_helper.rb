module FormHelper

  # Generic beginning of a form, wrapping form_with and yielding the builder
  def form_beginning attrs={}
    attrs[:model] ||= '#'
    attrs[:header] ||= 'Formulario'
    attrs[:turbo_frame] ||= '_top'
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

  # Input helpers for forms
  def _text_field label, object, field, element_type='1', attrs={}
    dom_id = "form_field_#{object}_#{field}"
    dom_class = "form_field element_#{element_type}"
    attrs[:name]  ||= "#{object}_#{field}_text"
    attrs[:type]  ||= 'd'
    attrs[:class] ||= (dom_class + ' input_form_field')
    output  = "<div id='#{dom_id}' class='#{dom_class}'><span class='form_field_label'>#{label}</span><br>"
    output += text_field(object, field, attrs)
    output += '</div>'
    return output.html_safe
  end

  # check_box
  def _checkbox label, object, field, element_type='2', attrs={}
    dom_id = "form_field_#{object}_#{field}"
    dom_class = "form_field element_#{element_type}"
    attrs[:name]  ||= "#{object}_#{field}_checkbox"
    attrs[:class] = "form_field #{attrs[:class]}"
    output  = "<div id='#{dom_id}' class='#{dom_class}'>"
    output += "<br>" if attrs[:down]
    label = "<span class='form_field_label #{attrs[:left] ? 'left' : 'right'}'>#{label}</span>".html_safe
    output += check_box(object, field, attrs) + label if attrs[:left]
    output += label + check_box(object, field, attrs) unless attrs[:left]
    output += '</div>'
    return output.html_safe
  end

  # check_box
  def old_checkbox rotulo, objeto, atributo, otros={}
    clase = otros[:clase]||'elemento'
    title = otros[:title] ? "title = '#{otros[:title]}'" : ""
    checked = otros[:checked]
    if otros[:izquierda]
      ('<div class="' + clase + '" ' + title + '>' + ( ("<br>" if otros[:abajo]) || "")).html_safe +  check_box( objeto, atributo, {checked: checked, disabled: otros[:disabled]} ) + rotulo + "</div>".html_safe
    else
      ('<div class="' + clase + '" ' + title + '>' + ( ("<br>" if otros[:abajo]) || "")).html_safe + rotulo + check_box( objeto, atributo, {checked: checked, disabled: otros[:disabled]} ) + "</div>".html_safe
    end
  end

end
