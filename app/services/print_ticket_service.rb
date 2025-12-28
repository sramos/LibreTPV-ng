class PrintTicketService < ApplicationService
  require 'mini_magick'
  
  def call(invoice)
    if printer_name = Config.value('PRINTER_NAME')
      # Print invoice ticket
      @printer = Escpos::Printer.new
      ticket_header
      ticket_body(invoice)
      ticket_footer(invoice)
      cut_and_send(printer_name)
      success
    end
  rescue => e
    Rails.logger.error "Error printing ticket: #{e.message}"
    failure(e)
  end

  private

  def ticket_header
    logo_image = Config.value('COMPANY_LOGO_FOR_TICKET')
    if File.exist?(logo_image)
      begin
        header = MiniMagick::Image.open(logo_image)
        header.combine_options do |c|
          c.resize "150x150>"
          c.background "white"
          c.extent "550x150"
          c.gravity "West"
          c.font "DejaVu-Sans-Bold"
          c.fill "black"
          c.pointsize "22"
          c.draw "text 170,-55 '#{Config.value('COMPANY_SHORT_NAME')}'" if Config.value('COMPANY_SHORT_NAME').present?
          c.font "DejaVu-Sans"
          c.pointsize "18"
          c.draw "text 170,-20 'NIF: #{Config.value('COMPANY_FISCAL_CODE')}'" if Config.value('COMPANY_FISCAL_CODE').present?
          c.draw "text 170,05 '#{Config.value('COMPANY_ADDRESS')}'" if Config.value('COMPANY_ADDRESS').present?
          c.draw "text 170,30 'Tel: #{Config.value('COMPANY_PHONE')}'" if Config.value('COMPANY_PHONE').present?
          c.draw "text 170,55 '#{Config.value('COMPANY_EMAIL')}'" if Config.value('COMPANY_EMAIL').present?
        end
        img_escpos = Escpos::Image.new(header.path, {
          processor: 'MiniMagick',
          extent: true
        })
        @printer.write(img_escpos.to_escpos)
      rescue
        @printer.write("ERROR CABECERA\n")
      end
    end
  end

  def ticket_body invoice
    full_line = ('-' * 48) + "\n"
    # Force CP858 encoding
    @printer.write("\x1B\x74\x13") # \x13 suele ser CP858 en muchas Epson/Approx. Si falla, prueba \x02
    @printer.write("\n")

    # Invoice data
    @printer.write(full_line)
    @printer.write(clear_text('Cliente' + ': ' + invoice.client.name_nif + "\n"))
    @printer.write(clear_text('Fecha' + ': ' + invoice.date.strftime('%d/%m/%Y %H:%M') + "\n"))
    @printer.write(clear_text('Factura' + ': ' + invoice.code + "\n"))
    @printer.write("\n")

    # Invoice lines
    invoice_vats = {}
    @printer.write(clear_text( format "%-41s   Imp.\n\n", 'Producto' ))
    invoice.note_lines.each do |line|
      line_name  = line.quantity > 1 ? "#{line.quantity} x " : ''
      line_name += line.product_name
      line_price = format("%.2f", line.total_amount_without_discount)

      @printer.write(clear_text( format "%-40s %6s\n", line_name[0..40], line_price ))
      if line.discount > 0
        discount_value = format("Descuento %.2f%%", line.discount_value)
        discounted_amount = format("%.2f", -line.discounted_amount)
        @printer.write(clear_text( format "      %-35s %6s\n", discount_value, discounted_amount ))
      end

      invoice_vats[line.product_vat_value] ||= {tax_base: 0, total_vat: 0}
      invoice_vats[line.product_vat_value][:tax_base] += line.tax_base
      invoice_vats[line.product_vat_value][:total_vat] += line.total_vat
    end

    # Invoice VATs
    @printer.write(full_line)
    @printer.write(clear_text( format "%-18s %-15s %6s\n", '', 'Base', 'C.IVA' ))
    invoice_vats.each do |type, value|
      vat_type = format("Iva %2s%%", type.to_s)
      tax_base = format("%.2f", value[:tax_base])
      tax_amount = format("%.2f", value[:total_vat])
      vat_line = format("   %-14s %-16s %6s\n", vat_type, tax_base, tax_amount)
      @printer.write( clear_text( vat_line ))
    end

    # Total amount for invoice
    @printer.write(full_line)
    @printer.write("\x1d\x21\x11") # Doble tamaño
    total_amount = format("%.2f", invoice.total_amount)
    @printer.write(clear_text( format "       TOTAL: %9s€\n", total_amount))
    @printer.write("\x1d\x21\x00") # Reset tamaño
    @printer.write(full_line)
    @printer.write("\n")
  end

  def ticket_footer invoice
    if Config.value('VERIFACTU_ENABLED') == 'TRUE'
      @printer.write("\e\x61\x01")
      begin
        nif = Rack::Utils.escape(Config.value('COMPANY_FISCAL_CODE'))
        invoice_number = Rack::Utils.escape(invoice.code)
        invoice_date = invoice.date.strftime('%d-%m-%Y')
        total_amount = invoice.total_amount
        url_verifactu = "https://www2.agenciatributaria.gob.es/wlpl/TOCP-MUTE/ValidacionQR?nif=#{nif}&num=#{invoice_number}&fecha=#{invoice_date}&total=#{total_amount}"
        qr_file = 'tmp/temp_qr.png'
        qr = RQRCode::QRCode.new(url_verifactu)
        png_qr = qr.as_png(
          bit_depth: 1,
          border_modules: 1,
          color_mode: ChunkyPNG::COLOR_GRAYSCALE,
          color: 'black',
          file: nil,
          fill: 'white',
          module_px_size: 4, # Tamaño de los puntos (ajustar si sale muy grande/pequeño)
          resize_exactly_to: false,
          resize_gte_to: false,
          size: 350 # Tamaño final en píxeles (ancho)
        )
        png_qr.save(qr_file)

        qr_image = Escpos::Image.new(qr_file, {
          processor: 'MiniMagick',
          extent: true
        })
        @printer.write(qr_image.to_escpos)
        @printer.write(clear_text("Veri*factu\n"))
        @printer.write(clear_text("Factura verificable en sede electrónica.\n"))
      rescue => e
        Rails.logger.error "Error QR: #{e.message}"
        @printer.write("[QR VERIFACTU ERROR]\n")
      end
    end
  end

  def cut_and_send printer_name
    @printer.write("\x1D\x56\x41\x03") # Cut paper

    Rails.logger.info "Printing ticket to printer: #{printer_name}"

    cmd = "lp -d #{printer_name}"
    begin
      escpos_data = @printer.to_escpos.force_encoding('ASCII-8BIT')
      
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        # Set binary mode for stdin
        stdin.binmode
        stdin.write(escpos_data)
        stdin.close
        
        stdout_str = stdout.read
        stderr_str = stderr.read
        status = wait_thr.value
        
        if status.success?
          success
        else
          Rails.logger.error "Error printing ticket: #{stderr_str}"
          failure(stderr_str)
        end
      end
    rescue IOError => e
      Rails.logger.error "Open3 stream error: #{e.message}"
      failure(e.message)
    rescue Encoding::UndefinedConversionError => e
      Rails.logger.error "Encoding error: #{e.message}"
      failure(e.message)
    end
  end

  def clear_text text
    spanish_map = {
      'ñ' => "\xA4", 'Ñ' => "\xA5",
      'á' => "\xA0", 'é' => "\x82", 'í' => "\xA1", 'ó' => "\xA2", 'ú' => "\xA3",
      'Á' => "\xB5", 'É' => "\x90", 'Í' => "\xD6", 'Ó' => "\xE0", 'Ú' => "\xE9",
      '€' => "\xD5", # Código CP858 para Euro (si falla usa 'EUR')
      'º' => "\xA7", 'ª' => "\xA6"
    }
    final_text = text.dup
    spanish_map.each { |char, hex| final_text.gsub!(char, hex) }
    # Build binary string to avoid encoding issues
    binary_text = final_text.force_encoding('ASCII-8BIT')
    return binary_text
  end
end
