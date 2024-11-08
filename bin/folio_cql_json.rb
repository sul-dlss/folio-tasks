# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])
limit = ARGV[1] || '10'
query = ARGV[2..]
folio.get_cql_json(path, limit, query.join(' '))
