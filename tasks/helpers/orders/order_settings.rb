# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate order settings
module OrderSettingsHelpers
  include FolioRequestHelper

  def acq_methods_tsv
    CSV.parse(File.open("#{Settings.tsv_orders}/acquisitions-methods.tsv"), headers: true,
                                                                            col_sep: "\t").map(&:to_h)
  end

  def custom_acq_methods_json
    JSON.parse(File.read("#{Settings.json}/orders/custom_acq_methods.json"))
  end

  def system_acq_methods_json
    JSON.parse(File.read("#{Settings.json}/orders/system_acq_methods.json"))
  end

  def pull_custom_acq_methods
    hash = @@folio_request.get('/orders/acquisition-methods?limit=99&query=source=="User"')
    trim_hash(hash, 'acquisitionMethods')
    hash.to_json
  end

  def pull_system_acq_methods
    hash = @@folio_request.get('/orders/acquisition-methods?limit=99&query=source=="System"')
    trim_hash(hash, 'acquisitionMethods')
    hash.to_json
  end

  def acq_methods_post(obj)
    @@folio_request.post('/orders/acquisition-methods', obj.to_json)
  end
end
