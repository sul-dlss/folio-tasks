# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/orders'
require_relative '../helpers/folio_jobs'

namespace :acquisitions do
  include FolioJobs, OrdersTaskHelpers

  desc 'multi-thread load SUL orders with pool size'
  task :load_sul_orders, [:size] do |_, args|
    batch_post_orders("#{Settings.json_orders}/sul", args[:size].to_i)
  end

  desc 'multi-thread load LAW orders with pool size'
  task :load_law_orders, [:size] do |_, args|
    batch_post_orders("#{Settings.json_orders}/law", args[:size].to_i)
  end
end
