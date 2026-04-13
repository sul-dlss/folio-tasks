# frozen_string_literal: true

# Module to encapsulate methods used by orders rake tasks to create po lines
module PoLinesHelpers
  include FolioRequestHelper

  def remove_encumbrance(po_line_hash)
    funds = po_line_hash.fetch('fundDistribution', [])
    return po_line_hash if funds.empty?

    funds.each do |obj|
      obj.delete('encumbrance')
    end
    po_line_hash
  end

  def orders_get_polines_po_num(po_number)
    @@folio_request.get("/orders/order-lines?query=poLineNumber==#{po_number}*")
  end

  def orders_get_polines(id)
    @@folio_request.get("/orders/order-lines/#{id}")
  end

  def orders_storage_put_polines(id, obj)
    @@folio_request.put("/orders-storage/po-lines/#{id}", obj)
  end
end
