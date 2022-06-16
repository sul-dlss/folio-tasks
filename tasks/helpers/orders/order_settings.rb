# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate order settings
module OrderSettingsHelpers
  include FolioRequestHelper

  def acq_methods_tsv
    CSV.parse(File.open("#{Settings.tsv_orders}/acquisitions-methods.tsv"), headers: true,
                                                                            col_sep: "\t").map(&:to_h)
  end

  def acq_methods_post(obj)
    @@folio_request.post('/orders/acquisition-methods', obj.to_json)
  end

  def po_lines_limit
    {
      'module' => 'ORDERS',
      'configName' => 'poLines-limit',
      'enabled' => true,
      'value' => '999'
    }
  end

  def po_lines_limit_post(obj)
    @@folio_request.post('/configurations/entries', obj.to_json)
  end
end
