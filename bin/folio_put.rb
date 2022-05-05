# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
path = ARGV[0]
json = File.read(ARGV[1])
folio = FolioRequest.new
folio.put(path, json)
