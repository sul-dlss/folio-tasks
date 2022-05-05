# frozen_string_literal: true

require_relative '../lib/folio_request'
require_relative '../lib/xml_user'

folio = FolioRequest.new

xml_user_result = XmlUser.new

xml_user_result.process_xml_lines(ARGV[0])

pp JSON.parse(xml_user_result.to_json)

puts "Users without affiliations: #{xml_user_result.non_affiliated_users}"

folio.post('/user-import', xml_user_result.to_json)
