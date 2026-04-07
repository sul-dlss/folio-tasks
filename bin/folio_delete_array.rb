# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])
json = JSON.parse(File.read(ARGV[1]))

# json file is an array of ID's to delete
# e.g. ["abc-123", "def-456"]

json.each do |obj|
  puts "DELETE #{path}/#{obj}"
  folio.delete("#{path}/#{obj}")
end
