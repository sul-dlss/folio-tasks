# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/orders'
require_rel '../helpers/uuids'
require_relative '../helpers/inventory'
require_relative '../../lib/folio_uuid'

namespace :acquisitions do
  include AcquisitionsUuidsHelpers, FolioRequestHelper, HoldingCodeHelpers, InventoryTaskHelpers, OrdersTaskHelpers,
          OrderTypeHelpers, PoLinesHelpers, Uuids

  desc 'transform SUL orders to folio orders'
  task :transform_sul_orders do
    transform_sul_orders
  end

  desc 'transform LAW orders to folio orders'
  task :transform_law_orders do
    transform_law_orders
  end

  desc 'report holding ID\'s for linking po lines, args filedir=sul or filedir=law'
  task :report_holding_id, [:filedir] do |_, args|
    data_dir = "#{Settings.json_orders}/#{args[:filedir]}"
    report_dir = "#{Settings.json_orders}/holdings_report/#{args[:filedir]}"
    report_holding_id(data_dir, report_dir)
  end

  desc 'delete sul folio order json files'
  task :delete_sul_order_json do
    data_dir = "#{Settings.json_orders}/sul"
    Dir.each_child(data_dir) { |i| File.delete("#{data_dir}/#{i}") }
  end

  desc 'delete law folio order json files'
  task :delete_law_order_json do
    data_dir = "#{Settings.json_orders}/law"
    Dir.each_child(data_dir) { |i| File.delete("#{data_dir}/#{i}") }
  end
end
