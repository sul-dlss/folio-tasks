# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/orders'
require_relative '../helpers/orders/po_lines'

namespace :orders do
  include OrdersTaskHelpers, PoLinesHelpers

  desc 'load orders given a library: sul or law'
  task :load_orders, [:filedir] do |_, args|
    post_composite_orders(args[:filedir])
    update_purchase_orders(args[:filedir])
  end

  desc 'link purchase orderlines to inventory given directory name'
  task :link_po_lines_to_inventory, [:filedir] do |_, args|
    link_po_lines_to_inventory(args[:filedir])
  end
end
