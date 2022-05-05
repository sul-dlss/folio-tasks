# frozen_string_literal: true

# Module to encapsulate methods used by acq_unit rake tasks
module AcquisitionsUnitsTaskHelpers
  # acquisitions units
  def acq_units_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/acquisitions-units.tsv"), headers: true,
                                                                                col_sep: "\t").map(&:to_h)
  end

  def acq_unit_id(name)
    response = FolioRequest.new.get_cql('/acquisitions-units-storage/units', "name==#{name}")['acquisitionsUnits']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def acq_unit_id_list(names)
    list = []
    names&.split(/,\s*/)&.each do |name|
      list << acq_unit_id(name)
    end
    # list = ['acq-123', 'acq-456']
    list
  end

  def acq_units_delete(id)
    FolioRequest.new.delete("/acquisitions-units-storage/units/#{id}")
  end

  def acq_units_post(obj)
    FolioRequest.new.post('/acquisitions-units-storage/units', obj.to_json)
  end
end
