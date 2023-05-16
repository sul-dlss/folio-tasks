# frozen_string_literal: true

require 'require_all'
require_rel '../helpers/orders'
require_relative '../helpers/uuids/acquisitions'
require_relative '../helpers/folio_jobs'

namespace :acquisitions do
  include AcquisitionsUuidsHelpers, FolioJobs, OrdersTaskHelpers

  desc 'multi-thread delete SUL orders from folio with pool size from json files'
  task :batch_delete_sul_orders_from_file, [:size] do |_, args|
    batch_delete_orders_from_file("#{Settings.json_orders}/sul_orders_loaded", args[:size].to_i)
  end

  desc 'multi-thread delete LAW orders from folio with pool size from json files'
  task :batch_delete_law_orders_from_file, [:size] do |_, args|
    batch_delete_orders_from_file("#{Settings.json_orders}/law_orders_loaded", args[:size].to_i)
  end

  desc 'multi-thread delete all orders from folio with pool size'
  task :delete_all_orders, [:size] do |_, args|
    batch_delete_orders(args[:size].to_i)
  end
end
