# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/po_lines'

namespace :orders do
  include PoLinesHelpers

  desc 'remove encumbrances from po lines'
  task :remove_encumbrances_po_line, [:file] do |_, args|
    File.readlines(args[:file], chomp: true).each do |id|
      next if id.empty?

      po_line = orders_get_polines(id)
      next if po_line.key?('errors')

      new_po_line = remove_encumbrance(po_line)
      puts 'New PO Line:'
      pp new_po_line
      orders_storage_put_polines(id, new_po_line)
    end
  end
end
