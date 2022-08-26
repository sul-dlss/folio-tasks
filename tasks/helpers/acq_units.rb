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
    @@folio_request.post('/acquisitions-units/units', obj.to_json)
  end

  def acq_units_assign(acq_unit_hash, membership_hash)
    TsvUserTaskHelpers.user_acq_units_and_permission_sets_tsv.each do |obj|
      acq_unit = obj['Acq Unit']
      acq_unit_id = acq_unit_hash[acq_unit]
      users = user_get(obj['SUNetID'])
      users && users['users'].each do |user|
        if acq_unit_id && !membership_hash[acq_unit_id + user['id']]
          acq_membership_obj = { 'userId' => user['id'], 'acquisitionsUnitId' => acq_unit_id }
          @@folio_request.post('/acquisitions-units/memberships', acq_membership_obj.to_json)
        end
      end
    end
  end
end
