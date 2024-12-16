# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate audit-data
module AuditDataHelpers
  include FolioRequestHelper

  def po_line_ids_file(filename)
    File.readlines("#{Settings.tsv}/orders/#{filename}", chomp: true)
  end

  def audit_acq_order_lines(id, **kwargs)
    limit = kwargs[:limit] ||= 10
    offset = kwargs[:offset] ||= 0
    path = "/audit-data/acquisition/order-line/#{id}?sortBy=action_date&sortOrder=desc&limit=#{limit}&offset=#{offset}"
    @@folio_request.get(path)
  end

  def previous_version_audit_event(po_line_audit_events)
    return [] unless po_line_audit_events.length == 2

    previous_event = po_line_audit_events.pop
    previous_event.dig('orderLineSnapshot', 'map')
  end
end
