class FindProductService < ApplicationService
  def call(isbn)
    cdl_data = FindProduct::CasadellibroService.call(isbn)
    if cdl_data.success? && cdl_data.payload && cdl_data.payload[:title]
      return cdl_data
    end
    ttl_data = FindProduct::TodostuslibrosService.call(isbn)
    return ttl_data
  rescue => e
    failure(e)
  end
end
