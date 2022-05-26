# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by acq_unit rake tasks
module AcquisitionsUnitsTaskHelpers
  include FolioRequestHelper

  # acquisitions units
  def acq_units_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/acquisitions-units.tsv"), headers: true,
                                                                                col_sep: "\t").map(&:to_h)
  end

  def acq_unit_id_list(names, acq_units_uuids)
    list = []
    names&.split(/,\s*/)&.each do |name|
      list << acq_units_uuids.fetch(name, nil)
    end
    # list = ['acq-123', 'acq-456']
    list
  end

  def acq_units_delete(id)
    @@folio_request.delete("/acquisitions-units-storage/units/#{id}")
  end

  def acq_units_post(obj)
    @@folio_request.post('/acquisitions-units-storage/units', obj.to_json)
  end
end
