require 'open-uri'

class FindProduct::LcdlService < ApplicationService
  def call(isbn)
    return_data = nil
    protocol = "https"
    host = 'www.todostuslibros.com'
    search = 'busquedas?isbn=' + isbn.to_s.strip

    Rails.logger.info  "[FindProduct::CasadellibroService] Buscando ISBN: #{isbn}"

    # Descargamos la página de resultados
    # https://api.empathy.co/search/v1/query/cdl/isbnsearch?internal=true&query=9788425366901&origin=url%3Aexternal&start=0&rows=24&instance=cdl&lang=es&scope=desktop&currency=EUR&store=ES
    html = URI.open("https://api.empathy.co/search/v1/query/cdl/isbnsearch?internal=true&query=#{isbn}&origin=url%3Aexternal&start=0&rows=24&instance=cdl&lang=es&scope=desktop&currency=EUR&store=ES").read

    # Parseamos la respuesta JSON
    response = JSON.parse(html)
    properties = response['catalog']['content'][0]

    ean = properties['ean']
    if properties && ean == isbn
      image_url = properties['__images'][0]
      price_value = properties['price']['previous'] || properties['price']['current'] if properties['price']
      data = {code: properties['ean'], authors: []}
      data[:title]  = properties['name'] if properties['name']
      data[:authors] = [ properties['author1'] ] if properties['author1']
      data[:authors] << properties['author2'] if properties['author2']
      data[:authors] << properties['author3'] if properties['author3']
      data[:authors] << properties['author4'] if properties['author4']
      data[:authors] << properties['author5'] if properties['author5']
      data[:publisher] = properties['editorial'] if properties['editorial']
      data[:edition] = properties['yearPublication'] if properties['yearPublication']
      data[:price] = price_value if price_value
      data[:image] = image_url if image_url
      data[:synopsis] = properties['description'] if properties['description']
      Rails.logger.debug "DATA: #{data.inspect}"
    end

    return_data = data unless data.empty? || data[:title].blank?

    success(return_data)
  rescue => e
    failure(e)
  end
end