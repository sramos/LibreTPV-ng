require 'open-uri'

class FindProduct::TtlService < ApplicationService
  def call(isbn)
    return_data = nil
    protocol = "https"
    host = 'www.todostuslibros.com'
    search = 'busquedas?isbn=' + isbn.to_s.strip

    Rails.logger.info  "[FindProduct::TodostuslibrosService] Buscando ISBN: #{isbn}"

    # Descargamos la página de resultados
    html = URI.open("#{protocol}://#{host}/#{search}").read

    # 1) Página de resultados: localizar el enlace cuyo bloque contenga el ISBN buscado
    doc = Nokogiri::HTML(html)

    # Info div has some fields (title, author, price, cover)
    # and info_all others (description, publisher)
    if info = doc.css('div#info')
      title_text  = info.at('h1.title')&.text&.strip

      authors = info.at('h2.author')&.css('a')&.collect{ |a| a.text&.to_s.strip }

      price_text  = info.at('div.total-book-price strong')&.text&.strip
      price_value = nil
      if price_text.present?
        # Eliminar símbolos de moneda y espacios, quedándonos con dígitos y separador decimal
        normalized = price_text.gsub(/[^0-9.,]/, '').tr(',', '.')
        price_value = normalized.to_f if normalized.present?
      end

      cover_image = nil
      info.css('img.portada').each do |img|
        src = img['src'].to_s
        next if src.blank? || src == '/img/nodisponible.gif'
        cover_image = src
        break
      end

      if detail_doc = doc.css('div#info_all')
        # Sinopsis: todos los párrafos dentro del div collapseSynopsis (id o clase)
        synopsis_paragraphs = detail_doc.css('div#collapseSynopsis p, div.collapseSynopsis p')
        synopsis_text = synopsis_paragraphs.map { |p| p.text.to_s.strip }.reject(&:blank?).join("\n\n")
      end

      data = {code: isbn}
      data[:title]  = title_text  if title_text.present?
      data[:authors] = authors if authors.any?
      data[:price]  = price_value if price_value
      data[:image]  = cover_image if cover_image.present?
      data[:synopsis] = synopsis_text if synopsis_text.present?

      return_data = data unless data.empty?
      Rails.logger.debug "DATA: #{data.inspect}"
    end

    success(return_data)
  rescue => e
    failure(e)
  end
end