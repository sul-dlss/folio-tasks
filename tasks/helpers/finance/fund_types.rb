# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate fund_type methods used by finance_settings rake tasks
module FundTypeHelpers
  include FolioRequestHelper

  def fund_types_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/fund-types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def fund_type_id(name)
    response = @@folio_request.get_cql('/finance/fund-types', "name==#{name}")['fundTypes']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def fund_types_delete(id)
    @@folio_request.delete("/finance/fund-types/#{id}")
  end

  def fund_types_post(obj)
    @@folio_request.post('/finance/fund-types', obj.to_json)
  end
end
