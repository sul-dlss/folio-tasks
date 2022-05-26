# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/orders'
require_relative '../helpers/acq_units'
require_relative '../helpers/finance/funds'
require_relative '../helpers/uuids'
require_relative '../../lib/folio_uuid'

namespace :acquisitions do
  include OrdersTaskHelpers, PoLinesHelpers, OrderTypeHelpers, HoldingCodeHelpers
  include AcquisitionsUnitsTaskHelpers
  include FundHelpers
  include Uuids

  desc 'load SUL orders into folio'
  task :load_orders_sul do
    acq_unit_uuid = acq_unit_id('SUL')
    order_type_map = order_type_mapping('order_type_map.tsv', Uuids.material_types)
    hldg_code_loc_map = hldg_code_map('sym_hldg_code_location_map.tsv', Uuids.sul_locations)
    uuid_hashes = [Uuids.tenant_addresses, Uuids.sul_organizations, order_type_map, hldg_code_loc_map, Uuids.sul_funds]
    order_yaml_dir = Settings.yaml.sul_orders.to_s
    order_json_dir = "#{Settings.json_orders}/sul"
    Dir.each_child(order_yaml_dir) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{order_yaml_dir}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, acq_unit_uuid, uuid_hashes)
      next if ENV['STAGE'] # so files are written when running tests

      File.open("#{order_json_dir}/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
        f.puts orders_post(folio_composite_orders).to_json
      end
      # the following doesn't seem to work well
      # write_json_to_file(order_json_dir, file, folio_composite_orders) unless ENV['STAGE']
      # okapi_response = orders_post(folio_composite_orders)
      # write_okapi_response_to_file(order_json_dir, file, okapi_response) unless ENV['STAGE']
    end
  end

  desc 'load LAW orders into folio'
  task :load_orders_law do
    acq_unit_uuid = acq_unit_id('Law')
    order_type_map = order_type_mapping('order_type_map.tsv', Uuids.material_types)
    hldg_code_loc_map = hldg_code_map('sym_hldg_code_location_map.tsv', Uuids.law_locations)
    uuid_hashes = [Uuids.tenant_addresses, Uuids.law_organizations, order_type_map, hldg_code_loc_map, Uuids.law_funds]
    order_yaml_dir = Settings.yaml.law_orders.to_s
    order_json_dir = "#{Settings.json_orders}/law"
    Dir.each_child(order_yaml_dir) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{order_yaml_dir}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, acq_unit_uuid, uuid_hashes)
      next if ENV['STAGE'] # so files are written when running tests

      File.open("#{order_json_dir}/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
        f.puts orders_post(folio_composite_orders).to_json
      end
      # the following doesn't seem to work well
      # write_json_to_file(order_json_dir, file, folio_composite_orders) unless ENV['STAGE']
      # okapi_response = orders_post(folio_composite_orders)
      # write_okapi_response_to_file(order_json_dir, file, okapi_response) unless ENV['STAGE']
    end
  end
end
