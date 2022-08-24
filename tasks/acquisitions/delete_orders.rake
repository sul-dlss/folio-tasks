# frozen_string_literal: true

require 'require_all'
require_rel '../helpers/orders'
require_relative '../helpers/uuids/acquisitions'

namespace :acquisitions do
  include AcquisitionsUuidsHelpers, OrdersTaskHelpers

  desc 'delete all orders from folio'
  task :delete_all_orders do
    orders_hash = AcquisitionsUuidsHelpers.orders
    orders_hash.values do |id|
      orders_delete(id)
    end
  end
end
