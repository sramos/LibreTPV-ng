class FindProductService < ApplicationService
  def call(isbn)
    ldl_data = FindProduct::LacasadellibroService.call(isbn)
    if ldl_data.success? && ldl_data.payload && ldl_data.payload[:title]
      return ldl_data
    end
    ttl_data = FindProduct::TodosTusLibrosService.call(isbn)
    return ttl_data
  rescue => e
    failure(e)
  end
end
