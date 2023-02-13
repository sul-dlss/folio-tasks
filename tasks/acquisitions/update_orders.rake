# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/orders'
require_relative '../helpers/folio_jobs'

namespace :acquisitions do
  include FolioJobs, OrdersTaskHelpers

  desc 'multi-thread modify orders with pool size and filedir=sul or filedir=law'
  task :update_orders_polines, [:size, :filedir] do |_, args|
    batch_put_orders_polines("#{Settings.json_orders}/#{args[:filedir]}", args[:size].to_i)
  end

  desc 'multi-thread modify only purchase orders with filedir=sul or filedir=law'
  task :update_orders, [:size, :filedir] do |_, args|
    batch_put_orders_storage_po("#{Settings.json_orders}/#{args[:filedir]}", args[:size].to_i)
  end
end
