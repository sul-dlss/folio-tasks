# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/orders'
require_rel '../helpers/uuids'
require_relative '../../lib/folio_uuid'

namespace :acquisitions do
  include OrdersTaskHelpers, PoLinesHelpers, OrderTypeHelpers, HoldingCodeHelpers, Uuids, AcquisitionsUuidsHelpers

  desc 'load SUL orders into folio'
  task :load_orders_sul do
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch('SUL', nil)
    order_type_map = order_type_mapping('order_type_map.tsv', Uuids.material_types,
                                        AcquisitionsUuidsHelpers.acquisition_methods)
    hldg_code_loc_map = hldg_code_map('sym_hldg_code_location_map.tsv', Uuids.sul_locations)
    uuid_hashes = [Uuids.tenant_addresses, AcquisitionsUuidsHelpers.sul_organizations, order_type_map,
                   hldg_code_loc_map, AcquisitionsUuidsHelpers.sul_funds]
    order_yaml_dir = Settings.yaml.sul_orders.to_s
    order_json_dir = "#{Settings.json_orders}/sul"
    Dir.each_child(order_yaml_dir) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{order_yaml_dir}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, acq_unit_uuid, uuid_hashes)
      next if ENV['STAGE'].eql?('test') # so files are not written when running tests

      File.open("#{order_json_dir}/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
        f.puts orders_post(folio_composite_orders).to_json
      end
    end
  end

  desc 'load LAW orders into folio'
  task :load_orders_law do
    acq_unit_uuid = AcquisitionsUuidsHelpers.acq_units.fetch('Law', nil)
    order_type_map = order_type_mapping('order_type_map.tsv', Uuids.material_types,
                                        AcquisitionsUuidsHelpers.acquisition_methods)
    hldg_code_loc_map = hldg_code_map('sym_hldg_code_location_map.tsv', Uuids.law_locations)
    uuid_hashes = [Uuids.tenant_addresses, AcquisitionsUuidsHelpers.law_organizations, order_type_map,
                   hldg_code_loc_map, AcquisitionsUuidsHelpers.law_funds]
    order_yaml_dir = Settings.yaml.law_orders.to_s
    order_json_dir = "#{Settings.json_orders}/law"
    Dir.each_child(order_yaml_dir) do |file|
      order_id, sym_order = get_id_data(YAML.load_file("#{order_yaml_dir}/#{file}"))
      folio_composite_orders = orders_hash(order_id, sym_order, acq_unit_uuid, uuid_hashes)
      next if ENV['STAGE'].eql?('test') # so files are not written when running tests

      File.open("#{order_json_dir}/#{file.tr('.yaml', '.json')}", 'w') do |f|
        f.puts folio_composite_orders.to_json
        f.puts orders_post(folio_composite_orders).to_json
      end
    end
  end
end
