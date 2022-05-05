# frozen_string_literal: true

# Module to encapsulate org category methods used by organizations rake tasks
module OrgCategoryTaskHelpers
  def category_map
    {
      '0' => category_id('Payments'),
      '1' => category_id('Customer%20Service'),
      '2' => category_id('Claims')
    }
  end

  def categories_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/organizations-categories.tsv"), headers: true,
                                                                                      col_sep: "\t").map(&:to_h)
  end

  def category_id(value)
    response = FolioRequest.new.get_cql('/organizations-storage/categories', "value==#{value}")['categories']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def categories_post(obj)
    FolioRequest.new.post('/organizations-storage/categories', obj.to_json)
  end
end
