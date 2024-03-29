# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'

folio = FolioRequest.new
path = folio.make_path(ARGV[0])
ARGV[1] && json = JSON.parse(File.read(ARGV[1]))
json ? folio.post(path, json.to_json) : folio.post_no_body(path)
