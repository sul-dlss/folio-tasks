# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])
json = JSON.parse(File.read(ARGV[1]))

json.each do |obj|
  folio.post(path, obj.to_json)
end
