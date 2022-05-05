# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
path = ARGV[0]
query = ARGV[1]
folio = FolioRequest.new
folio.get_cql_json(path, query)
