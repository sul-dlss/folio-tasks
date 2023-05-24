# frozen_string_literal: true

require 'csv'
require 'require_all'
require_rel '../helpers/orders'

namespace :orders do
  include OrderTagHelpers

  desc 'load SUL tags for orders'
  task :load_order_tags_sul do
    order_tags('order_xinfo_sul.tsv').each do |tag|
      post_tags(tag_hash(tag))
    end
  end
end
