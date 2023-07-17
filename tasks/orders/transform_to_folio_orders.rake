# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/orders'
require_rel '../helpers/uuids'
require_relative '../../lib/folio_uuid'

namespace :orders do
  include AcquisitionsUuidsHelpers, FolioRequestHelper, HoldingCodeHelpers, OrdersTaskHelpers, OrderTypeHelpers,
          PoLinesHelpers, Uuids

  desc 'transform SUL orders to folio orders'
  task :transform_sul_orders do
    transform_sul_orders
  end

  desc 'transform LAW orders to folio orders'
  task :transform_law_orders do
    transform_law_orders
  end

  desc 'delete sul folio order json files'
  task :delete_sul_order_json do
    data_dirs = ["#{Settings.json_orders}/sul", "#{Settings.json_orders}/sul_orders_loaded",
                 "#{Settings.json_orders}/sul_polines_linked"]
    data_dirs.each do |directory|
      Dir.each_child(directory) { |i| File.delete("#{directory}/#{i}") }
    end
  end

  desc 'delete law folio order json files'
  task :delete_law_order_json do
    data_dirs = ["#{Settings.json_orders}/law", "#{Settings.json_orders}/law_orders_loaded",
                 "#{Settings.json_orders}/law_polines_linked"]
    data_dirs.each do |directory|
      Dir.each_child(directory) { |i| File.delete("#{directory}/#{i}") }
    end
  end
end
