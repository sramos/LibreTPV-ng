require 'open-uri'

class FindProduct::TodosTusLibrosService < ApplicationService
  def call(isbn)
    return_data = nil
    protocol = "https"
    host = 'www.todostuslibros.com'
    search = 'busquedas?isbn=' + isbn.to_s.strip

    Rails.logger.info  "-----------------> Buscando en TTL: " + search

    # Descargamos la página de resultados
    html = URI.open("#{protocol}://#{host}/#{search}").read

    # 1) Página de resultados: localizar el primer enlace al detalle del libro
    doc = Nokogiri::HTML(html)
    result_link = doc.at('div.book-details h2.title a')

    if result_link && result_link['href'].present?
      detail_url = result_link['href']
      Rails.logger.info  "-----------------> Detalle TTL: #{detail_url}"

      # 2) Página de detalle: extraer título, autor, precio e imagen de portada
      detail_html = URI.open(detail_url).read
      detail_doc  = Nokogiri::HTML(detail_html)

      title_text  = detail_doc.at('h1.title')&.text&.strip
      author_text = detail_doc.at('h2.author a')&.text&.strip

      price_text  = detail_doc.at('div.total-book-price strong')&.text&.strip
      price_value = nil
      if price_text.present?
        # Eliminar símbolos de moneda y espacios, quedándonos con dígitos y separador decimal
        normalized = price_text.gsub(/[^0-9.,]/, '').tr(',', '.')
        price_value = normalized.to_f if normalized.present?
      end

      cover_image = nil
      detail_doc.css('img.portada').each do |img|
        src = img['src'].to_s
        next if src.blank? || src == '/img/nodisponible.gif'
        cover_image = src
        break
      end

      # Sinopsis: todos los párrafos dentro del div collapseSynopsis (id o clase)
      synopsis_paragraphs = detail_doc.css('div#collapseSynopsis p, div.collapseSynopsis p')
      synopsis_text = synopsis_paragraphs.map { |p| p.text.to_s.strip }.reject(&:blank?).join("\n\n")

      data = {}
      data[:title]  = title_text  if title_text.present?
      data[:author] = author_text if author_text.present?
      data[:price]  = price_value if price_value
      data[:image]  = cover_image if cover_image.present?
      data[:synopsis] = synopsis_text if synopsis_text.present?

      return_data = data unless data.empty?
    end

    success(return_data)
  rescue => e
    failure(e)
  end
end