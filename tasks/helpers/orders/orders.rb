# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate methods used by orders rake tasks
module OrdersTaskHelpers
  include FolioRequestHelper

  def orders_post(obj)
    @@folio_request.post('/orders/composite-orders', obj.to_json, response_code: true)
  end

  def orders_put(id, obj)
    @@folio_request.put("/orders/composite-orders/#{id}", obj.to_json)
  end

  def orders_storage_put_po(id, obj)
    @@folio_request.put("/orders-storage/purchase-orders/#{id}", obj.to_json, response_code: true)
  end

  def orders_delete(id)
    @@folio_request.delete("/orders/composite-orders/#{id}")
  end
end
