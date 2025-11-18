class FindProductService < ApplicationService
  def call(isbn)
    FindProduct::TodosTusLibrosService.call(isbn)
  rescue => e
    failure(e)
  end
end
