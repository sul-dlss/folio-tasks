# frozen_string_literal: true

require 'date'
require 'csv'
require_relative '../lib/folio_request'
require_relative '../tasks/helpers/orders/po_lines'
require_relative '../tasks/helpers/folio_request'

sul_json_orders_dir = "#{Settings.json_orders}/sul"
sul_report_dir = "#{Settings.json_orders}/holdings_report/sul"

file_prefix = DateTime.now.strftime('%y%m%d%H%M') # e.g. 2302231456
report_name = 'holdings_lookup_report.tsv'
file_name = "#{sul_report_dir}/#{file_prefix}_#{report_name}"

CSV.open(file_name, 'w', col_sep: "\t",
                         write_headers: true,
                         headers: ['Order ID', 'PO line number', 'Holdings result']) do |csv|
  Dir.each_child(sul_json_orders_dir) do |file|
    po = JSON.parse(File.read("#{sul_json_orders_dir}/#{file}"))
    po_number = po['poNumber']
    po['compositePoLines'].each_with_index do |po_line, ix|
      csv_row = []
      next if po_line['locations'][0]['locationId'].nil?

      instance_id = po_line['instanceId']
      location_id = po_line['locations'][0]['locationId']
      call_num = po_line['edition']
      csv_row.push(po_number, ix)
      results_no_callnum = holding_no_callnum(instance_id, location_id) # nil if response = 0
      # nil if response != 1
      results_with_callnum = holding_with_callnum(instance_id, location_id, call_num) unless call_num.nil?
      if results_with_callnum.nil? && !results_no_callnum.nil?
        csv_row.push('No match with callnum, use first of multiple matches without callnum')
      elsif results_no_callnum.nil? || results_with_callnum.nil?
        csv_row.push('No matches with or without callnum')
      else # results_with_callnum is 1
        csv_row.push('Exactly 1 match with callnum')
      end
      csv << csv_row
    end
  end
end

law_json_orders_dir = "#{Settings.json_orders}/law"
law_report_dir = "#{Settings.json_orders}/holdings_report/law"

file_prefix = DateTime.now.strftime('%y%m%d%H%M') # e.g. 2302231456
report_name = 'holdings_lookup_report.tsv'
file_name = "#{law_report_dir}/#{file_prefix}_#{report_name}"

CSV.open(file_name, 'w', col_sep: "\t",
                         write_headers: true,
                         headers: ['Order ID', 'PO line number', 'Holdings result']) do |csv|
  Dir.each_child(law_json_orders_dir) do |file|
    po = JSON.parse(File.read("#{law_json_orders_dir}/#{file}"))
    po_number = po['poNumber']
    po['compositePoLines'].each_with_index do |po_line, ix|
      csv_row = []
      next if po_line['locations'][0]['locationId'].nil?

      instance_id = po_line['instanceId']
      location_id = po_line['locations'][0]['locationId']
      call_num = po_line['edition']
      csv_row.push(po_number, ix)
      results_no_callnum = holding_no_callnum(instance_id, location_id) # nil if response = 0
      # nil if response != 1
      results_with_callnum = holding_with_callnum(instance_id, location_id, call_num) unless call_num.nil?
      if results_with_callnum.nil? && !results_no_callnum.nil?
        csv_row.push('No match with callnum, use first of multiple matches without callnum')
      elsif results_no_callnum.nil? || results_with_callnum.nil?
        csv_row.push('No matches with or without callnum')
      else # results_with_callnum is 1
        csv_row.push('Exactly 1 match with callnum')
      end
      csv << csv_row
    end
  end
end
