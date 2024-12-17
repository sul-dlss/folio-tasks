# frozen_string_literal: true

require 'csv'
require_relative '../helpers/orders/po_lines'
require_relative '../helpers/audit_data'

namespace :orders do
  include AuditDataHelpers
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

  desc 'restore previous po line version'
  task :restore_po_line, [:file] do |_, args|
    po_line_ids = po_line_ids_file(args[:file])
    po_line_ids.each do |id|
      next if id.empty?

      audit_events = audit_acq_order_lines(id, limit: 2, offset: 0)
      po_line_audit_events = audit_events.fetch('orderLineAuditEvents', [])
      previous_version = previous_version_audit_event(po_line_audit_events)
      if previous_version.empty?
        puts "No audit events to restore for po line #{id}"
      else
        response = orders_storage_put_polines(id, previous_version)
        if response == 204
          puts "#{id} po line successfully updated"
        else
          puts "ERROR: #{id} po line not updated"
        end
      end
    end
  end
end
