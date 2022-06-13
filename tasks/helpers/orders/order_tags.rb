# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate methods to create order tags used by orders rake tasks
module OrderTagHelpers
  include FolioRequestHelper

  def order_tags_tsv(file)
    CSV.parse(File.open("#{Settings.tsv_orders}/#{file}"), headers: true, col_sep: "\t",
                                                           liberal_parsing: true).map(&:to_h)
  end

  def order_tags(file)
    tag_list = []
    order_tags_tsv(file).each do |row|
      tag_list.push(combine(row['XINFO_FIELD'], row['DATA'])) if row['XINFO_FIELD'].match?(/DATA|BIGDEAL/)
    end
    tag_list.uniq
  end

  def tag_hash(tag)
    {
      'label' => tag
    }
  end

  def post_tags(obj)
    @@folio_request.post('/tags', obj.to_json)
  end

  def combine(field, data)
    "#{add_label(field)}#{cleanup_tag_data(data)}"
  end

  def add_label(data)
    data.gsub(/^/, 'SUL').gsub(/$/, ':')
  end

  def cleanup_tag_data(data)
    # strip subfield "a" from the beginning and "<ENTRY" from the end of DATA, replace spaces with underscores
    data.gsub(/^a{1}/, '').gsub(/<ENTRY$/, '').tr(' ', '_')
  end
end
