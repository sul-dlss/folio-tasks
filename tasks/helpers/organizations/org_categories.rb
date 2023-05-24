# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate org category methods used by organizations rake tasks
module OrgCategoryTaskHelpers
  include FolioRequestHelper

  def categories_csv
    CSV.parse(File.open("#{Settings.tsv}/organizations/organizations-categories.tsv"), headers: true,
                                                                                       col_sep: "\t").map(&:to_h)
  end

  def category_id(value)
    response = @@folio_request.get_cql('/organizations-storage/categories', "value==#{value}")['categories']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def categories_post(obj)
    @@folio_request.post('/organizations-storage/categories', obj.to_json)
  end
end
