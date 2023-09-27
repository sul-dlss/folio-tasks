# frozen_string_literal: true

require_relative '../lib/illiad'
require_relative '../lib/folio_request'
require_relative '../lib/xml_user'

folio = FolioRequest.new

xml_user_result = XmlUser.new

xml_user_result.process_xml_lines(ARGV[0])

user_json = xml_user_result.to_json

folio_response = folio.post('/user-import', user_json)

# File used for emailing the user import result
File.open('userload-harvest/log/user-import-response.log', 'a') do |f|
  log_json = {
    'batch_number' => ARGV[1],
    'batch_response' => folio_response,
    'non_affiliated_users' => xml_user_result.non_affiliated_users
  }.to_json

  f.write "#{log_json}\n"
end

# out to userload.log file
puts user_json

illiad = Illiad.new(xml_user_result.to_hash)

illiad_users = illiad.load_illiad_users

puts illiad_users

