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
    audit_events = @@folio_request.get("/audit-data/acquisition/order-line/#{id}?sortBy=action_date&sortOrder=desc&limit=#{limit}&offset=#{offset}")
  end

  def previous_version_audit_event(po_line_audit_events)
    if (po_line_audit_events.length == 2)
      previous_event = po_line_audit_events.pop
      previous_event.dig('orderLineSnapshot', 'map')
    else
      return []
    end
  end
end
