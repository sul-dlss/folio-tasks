# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate finance group methods used by finance_settings rake tasks
module FinanceGroupHelpers
  include FolioRequestHelper

  def finance_groups_csv
    CSV.parse(File.open("#{Settings.tsv}/finance/finance-groups.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def finance_groups_hash(obj, acq_units_uuids)
    acq_unit_ids = acq_unit_id_list(obj['acqUnit_name'], acq_units_uuids)
    obj['acqUnitIds'] = acq_unit_ids unless acq_unit_ids&.empty?
    obj.delete('acqUnit_name')

    obj
  end

  def finance_groups_delete(id)
    @@folio_request.delete("/finance/groups/#{id}")
  end

  def finance_groups_post(obj)
    @@folio_request.post('/finance/groups', obj.to_json)
  end
end
