# frozen_string_literal: true

require_relative '../lib/folio_request'
require_relative '../lib/xml_user'

folio = FolioRequest.new

xml_user_result = XmlUser.new

xml_user_result.process_xml_lines(ARGV[0])

puts xml_user_result.to_json

folio_response = folio.post('/user-import', user_json)

non_affiliated_users = "Users without affiliations: #{xml_user_result.non_affiliated_users}"

File.open('log/user-import-response.log', 'w') do |f|
  f.write "----------batch: #{ARGV[1]} ----------"
  f.write folio_response
  f.write non_affiliated_users
end
