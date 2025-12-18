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
          c.draw "text 170,-30 '#{Config.value('COMPANY_SHORT_NAME')}'" if Config.value('COMPANY_SHORT_NAME').present?
          c.font "DejaVu-Sans"
          c.pointsize "18"
          c.draw "text 170,05 '#{Config.value('COMPANY_FISCAL_CODE')}'" if Config.value('COMPANY_FISCAL_CODE').present?
          c.draw "text 170,30 '#{Config.value('COMPANY_ADDRESS')}'" if Config.value('COMPANY_ADDRESS').present?
          c.draw "text 170,55 '#{Config.value('COMPANY_PHONE')}'" if Config.value('COMPANY_PHONE').present?
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
    @printer.write(clear_text('Cliente' + ': ' + invoice.client.name + "\n"))
    @printer.write(clear_text('Fecha' + ': ' + invoice.date.strftime('%d/%m/%Y %H:%M') + "\n"))
    @printer.write(clear_text('Factura Simpl' + ': ' + invoice.code + "\n"))
    @printer.write("\n")

    # Invoice lines
    invoice_lines = []
    invoice_vats = {}
    any_discount = false
    invoice.note_lines.each do |line|
      line_name  = line.quantity > 1 ? "#{line.quantity} x " : ''
      line_name += line.product_name
      discount = line.discount > 0 ? "#{line.discount_value} %" : ''
      any_discount = true if line.discount > 0
      invoice_lines << {name: line_name, discount: discount, total: format("%.2f", line.total_amount)}
      invoice_vats[line.product_vat_value] ||= {tax_base: 0, total_vat: 0}
      invoice_vats[line.product_vat_value][:tax_base] += line.tax_base
      invoice_vats[line.product_vat_value][:total_vat] += line.total_vat
    end

    # Print lines with or without discount
    if any_discount
      @printer.write(clear_text( format "%-36s Dto.   Imp.\n\n", 'Producto' ))
      invoice_lines.each do |line|
        @printer.write(clear_text( format "%-36s %4s %6s\n", line[:name][0..36], line[:discount], line[:total] ))
      end
    else
      @printer.write(clear_text( format "%-41s   Imp.\n\n", 'Producto' ))
      invoice_lines.each do |line|
        @printer.write(clear_text( format "%-41s %6s\n", line[:name][0..41], line[:total] ))
      end
    end

    # Invoice VATs
    @printer.write(full_line)
    #cadena += format " %-41s %6s\n", "Subtotal", format("%.2f",subtotal)
    invoice_vats.each do |type, value|
      @printer.write( clear_text( format " %-40s %6s\n", format("Iva ( %2s%% )",type.to_s), format("%.2f", value[:total_vat]) ))
    end

    # Total amount for invoice
    @printer.write("\x1d\x21\x11") # Doble tamaño
    @printer.write(clear_text( format "TOTAL: %9s €\n", invoice.total_amount))
    @printer.write("\x1d\x21\x00") # Reset tamaño
    @printer.write(full_line)
    @printer.write("\n")
  end

  def ticket_footer invoice
  end

  def cut_and_send printer_name
    @printer.write("\x1D\x56\x41\x03") # Cut paper

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
