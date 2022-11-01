# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])
query = ARGV[1]
json = JSON.parse(File.read(ARGV[2]))

json.each do |obj|
  puts "DELETE #{path}/#{obj}?#{query}"
  folio.delete("#{path}/#{obj}?#{query}")
end
