#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2013 Santiago Ramos <sramos@sitiodistinto.net>
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo
#    bajo los términos de la Licencia Pública General GNU publicada
#    por la Fundación para el Software Libre, ya sea la versión 3
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO.
#    Consulte los detalles de la Licencia Pública General GNU para obtener
#    una información más detallada.
#
#    Debería haber recibido una copia de la Licencia Pública General GNU
#    junto a este programa.
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++



# Methods added to this helper will be available to all templates in the application.
module OldApplicationHelper

  #--
  # METODOS GENERALES
  #++

  # Obtiene el valor de un campo
  def obtiene_valor_campo valor, campo
    campo.split('.').each do |metodo|
      valor = (metodo =~ /(\S+)\s(\S+)/ ? valor.send($1,$2) : valor.send(metodo)) if valor
    end
    return valor
  end

  def cabecera_listado tipo, otros={}
    # Sacamos los campos a mostrar bien vengan como array (posicion global) o como tipo
    @campos_listado = tipo.is_a?(Array) ? tipo : campos_listado(tipo)
    # Dibujamos la cabecera del listado
    cadena = "<div class='listado'><div class='listadocabecera'>"
    for campo in @campos_listado
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_etiqueta_" + campo + "'>" + etiqueta(campo)[0] + "</div>"
    end
    cadena += "<div class='listado_derecha'>"
    cadena += link_to( icono( "Download", {:title => "Exportar a XLS"}), request.parameters.merge({:format => :xls, :format_xls_count => (@formato_xls.to_i+1)}) ) if @formato_xls
    cadena += modal icono('Plus',{:title => "Nuevo"}), otros[:url], otros[:title] || "Nuevo" if otros[:url]
    cadena += "</div></div>"
    return cadena.html_safe
  end

  def fila_listado objeto, id=nil
    cadena = ""
    i=0
    for campo in @campos_listado
      if objeto.class.name == "Array"
        valor=objeto[i] || ""
      else
        #valor=objeto
        #campo.split('.').each { |metodo| valor = valor.send(metodo) if valor } if objeto
        valor = obtiene_valor_campo objeto, campo
      end
      i += 1
      etiqueta=etiqueta(campo)
      valor = valor.localtime.strftime("%d/%m/%Y %H:%M:%S") if valor.class.name == "ActiveSupport::TimeWithZone"
      valor = "Sí" if valor.class.name == "TrueClass"
      valor = "No" if valor.class.name == "FalseClass" && campo != "valor_defecto"
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta[1] + (etiqueta[3]||"") + "' id='listado_campo_valor_" + campo + (objeto.class.name == "Array" ? "" : "_" + objeto.id.to_s) + "' title='" + (valor ? valor.to_s : "&nbsp;") + "'>" + (valor && valor.to_s != "" ? truncate( (etiqueta[3]=="f"?sprintf("%.2f",valor):valor.to_s), :length => etiqueta[2]):"&nbsp;") + '</div>'
    end
    #cadena += "</div>"
    return cadena.html_safe
  end

  def final_listado *objeto
    cadena = ""
    #cadena << "<div class='linea' id='paginado'><br/></div><div class='elemento_derecha'>" + (will_paginate(objeto) || "") + "</div>" if !objeto.nil?
    cadena += paginacion( objeto[0], session[:por_pagina] ) if objeto[0]
    cadena += "</div>"
    return cadena.html_safe
  end

  def cabecera_sublistado rotulo, tipo, sub_id, nuevo={}, clase="sublistado"
    #@campos_sublistado = campos
    @campos_sublistado = tipo.is_a?(Array) ? tipo : campos_listado(tipo)
    cadena = '<br><fieldset class="' + clase + '"> <legend>'+ rotulo +'</legend>'
    cadena += '<div class="listado_derecha" id="cerrarsublistado">'
    cadena += link_to( icono( "Download", {:title => "Exportar a XLS"}), request.parameters.merge({:format => :xls}) ) if @formato_xls
    cadena += link_to(icono('Cancel', {title: "Ocultar"}), "#",
                      id: sub_id + "_ocultar_sublistado",
                      onclick: "document.getElementById('#{sub_id}').innerHTML=''; return false;") if sub_id
    cadena += "</div><br/><br/><div class='listadocabecera'>"
    for campo in @campos_sublistado
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='sublistado_campo_valor_" + campo + "' >" + etiqueta(campo)[0] + "</div>"
    end
    if nuevo[:url] && nuevo[:title]
      cadena += '<div class="listado_derecha">'
      cadena += modal(icono('Plus',{:title => nuevo[:title]}), nuevo[:url], nuevo[:title])
      cadena += '</div>'
    end
    cadena += '</div>'
    return cadena.html_safe
  end

  def fila_sublistado objeto
    cadena = ""
    for campo in @campos_sublistado
      #valor=objeto
      #campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      valor = obtiene_valor_campo objeto, campo
      valor = format('%0.2f',valor) if etiqueta(campo)[3] == "f" && valor
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_valor_" + campo + "' title='" + (valor ? valor.to_s : "&nbsp;") + "'>" + (valor && valor.to_s != "" ? truncate(valor.to_s, :length => etiqueta(campo)[2]):"&nbsp;") + '</div>'
    end
    return cadena.html_safe
  end

  # Dibuja los elementos del final del sublistado.
  def final_sublistado
      return "</fieldset>".html_safe
  end

  def texto rotulo, objeto, atributo, valor=nil, otros={}
    cadena = ("<div class='elemento'>" + rotulo +"<br/>").html_safe
    html_id = otros[:id] || "formulario_campo_#{objeto}_#{atributo}"
    opciones = {class: 'texto', id: html_id, type: 'd' }
    opciones[:value] = valor if valor
    if otros[:autocomplete]
      cadena << text_field_with_auto_complete( objeto, atributo, {:class => "texto"}, {:method => :get, :with => "'search=' + element.value"} )
    else
      cadena << text_field( objeto, atributo, opciones)
    end
    return cadena + "</div>".html_safe
  end

  def texto_area rotulo , objeto, atributo, otros={}
    cadena = ""
    title = (otros[:title] || otros[:placeholder]) if otros[:title] || otros[:placeholder]
    otros[:name] ||= "#{objeto}[#{atributo}]"
    opciones = {type: "d", name: otros[:name]}
    opciones[:rows] = otros[:rows] if otros[:rows]
    opciones[:value] = otros[:value] if otros[:value]
    opciones[:placeholder] = otros[:placeholder] if otros[:placeholder]
    opciones[:title] = title if title
    opciones[:class] = "textoarea"+otros[:clase].to_s
    opciones[:rows] = 3
    cadena = ("<div class='textoarea#{otros[:clase]}' title='#{title}'>").html_safe + rotulo + '<br/>'.html_safe + text_area( objeto, atributo , opciones)
    return cadena << "</div>".html_safe
  end


  def fecha rotulo, objeto, atributo, valor=nil, discards=[false, false]
    cadena = ("<div class='elemento_x1'>" + rotulo + "<br/>").html_safe
    #cadena << date_select(objeto, atributo, {:discard_day=>discards[0], :discard_month=>discards[1], :order => [:day,:month,:year], :class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :default => valor})
    otros = {}
    year_range = [2010, Time.now.year + 5]
    otros[:min] = Date.new(year_range[0])
    otros[:max] = Date.new(year_range[1])
    otros[:size] = "10"
    otros[:value] = I18n.l(valor) if valor
    #cadena << calendar_date_select(objeto, atributo, otros)
    #puts "---> valor: " + valor.inspect
    cadena += date_field(objeto, atributo, otros)
    cadena += "</div>".html_safe
    return cadena
  end

  def fecha_mes rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,false]
  end

  def fecha_anno rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,true]
  end

  #def selector rotulo, objeto, atributo, valores, valor=nil, tipo=nil, vacio=false
  def selector rotulo, objeto, atributo, valores, opciones={}
    cadena = ("<div class='elemento_" + (opciones[:tipo] || "x15") + "' id='selector_" + objeto + "_" + atributo + "'>" + rotulo + "<br/>").html_safe
    clase = opciones[:enriquecido] ? "chosen_select " : ""
    clase += (opciones[:tipo] || 'selector_x15')
    html_id = opciones[:id] || "formulario_campo_" + objeto + "_" + atributo
    select_options = {include_blank: opciones[:vacio], disabled: opciones[:disabled]}
    select_options[:selected] = opciones[:valor] if opciones[:valor]
    cadena << select(objeto, atributo, valores, select_options, {id: html_id, class: clase})
    cadena += "</div>".html_safe
    return cadena
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

  # dibuja un mensage flash
  def mensaje msg
    ("<div id = 'mensaje'>" + msg + "</div>").html_safe if msg
  end

  # dibuja un mensaje flash de exito
  def ok_message msg
    ("<div id = 'mensajeok'>" + msg + "</div>").html_safe if msg
  end

  # dibuja el mensaje de error o de exito
  def mensaje_error objeto, otros={}
    if objeto.class == String && !objeto.blank?
      cadena = '<div id="mensajeerror">'.html_safe
      cadena << objeto.html_safe
    else
      if objeto.blank? || objeto.errors.empty?
        cadena = '<div id="mensajeok">'.html_safe
        cadena << "Los datos se han guardado correctamente.".html_safe unless otros[:borrar]
        cadena << "Se ha eliminado correctamente.".html_safe if otros[:borrar]
      else
        cadena = '<div id="mensajeerror">'.html_safe
        cadena << "Se ha producido un error.".html_safe + "<br>".html_safe
        objeto.errors.each {|a, m| cadena += (m + "<br>").html_safe }
      end
    end
    cadena << "</div>".html_safe
    return cadena
  end

 # Sustituye al helper de auto_complete para presentar los resultados
 def auto_complete_result_2(entries, field, phrase = nil)
    return unless entries
    items = entries.map { |entry| phrase ? highlight(entry[field], phrase) : h(entry[field]) }
    result = "<ul>"
    items.uniq.each { |li|
      result << "<li>" + li + "</li>"
    }
    result << "<ul>"
    return result.html_safe
  end

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end

  # Devuelve las secciones disponibles para el usuario
  def menu_secciones user=nil
    sections = {
      sales: {url: sales_client_notes_path, label: 'Caja'},
      products: {url: products_products_path, label: 'Productos'},
      accounting: {url: '/accounting/caja', label: 'Tesorería'},
      #distribution: {url: '/editor/products', label: 'Distribuidora'},
      admin: {url: admin_authors_path, label: 'Administración'}
    }
    if user && user.class.name == "User"
      sections = sections.select{|k, v| user.granted?(k) }
    else
      {}
    end
    sections
  end

  def menu_controladores controlador={}
    controladores = []
    case params[:section]&.to_sym
      when :sales
        controladores = [ #{ label: 'Pedidos', controlador: 'pedidos' },
                          { label: 'Facturas Clientes', controlador: 'sales/client_invoices' },
                          { label: 'Clientes', controlador: 'sales/clients' },
                          { label: 'Entradas/Salidas de Caja', controlador: 'sales/cash' },
                          { label: 'Ventas/Devoluciones', controlador: 'sales/client_notes' }
                        ]
      when :products
        controladores = [ #{ label: 'Facturas Proveedores', controlador: 'factura' },
                          #{ label: 'Depósitos', controlador: 'deposito' },
                          #{ label: 'Albaranes aceptados', controlador: 'albaranes_cerrados' },
                          #{ label: 'Albaranes de entrada', controlador: 'albarans' },
                          { label: 'Proveedores', controlador: 'products/suppliers' },
                          { label: 'Inventario', controlador: 'products/products' } ]
      when :accounting
        controladores = [ { label: 'Informes', controlador: 'informe' },
                          { label: 'Libro diario', controlador: 'libro_diario' },
                          { label: 'Posicion global', controlador: 'posicion_global' },
                          { label: 'Arqueo/Cierre de Caja', controlador: 'caja' },
                          { label: 'Facturas de Servicios', controlador: 'factura' }  ]
      when "trueke"
        controladores = [ { label: 'Cambios', controlador: 'cambio' } ]
      when :distributor
        controladores = [ { label: 'Facturas librerías', controlador: 'factura' },
                          { label: 'Albaranes de envío', controlador: 'albarans' },
                          { label: 'Almacenes', controlador: 'almacenes' },
                          { label: 'Inventario', controlador: 'productos_editorial' }
                        ]
      when :admin
        controladores = [ { label: 'Usuarios', controlador: 'admin/users' },
                          #{ label: 'Backup', controlador: 'backup' },
                          #{ label: 'Recuperar Objetos', controlador: 'perdidos' },
			                    { label: 'Parámetros', controlador: 'admin/configs' },
                          { label: 'Formas de Pago', controlador: 'admin/payment_types' },
                          { label: 'Tipos de IVA', controlador: 'admin/vats' },
                          { label: 'Tipos de Producto', controlador: 'admin/product_types' },
                          { label: 'Editoriales', controlador: 'admin/publishers' },
                          { label: 'Autores', controlador: 'admin/authors' },
                          #{ label: 'Avisos', controlador: 'avisos' }
                        ]

    end
    return controladores
  end

  def controlador_rotulo controlador={}
    rotulo="LibreTPV"
    menu_controladores.each{|elemento| rotulo = elemento[:label] if elemento[:controlador] == controlador}
    return rotulo
  end
end
