# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])

def usage
  puts 'USAGE: folio_cql_json.rb {folio API path} {limit (optional, default 10)} {cql query string}'
  exit(0)
end

usage if ARGV.length < 2

if ARGV.length == 2
  query = ARGV[1..]
else
  limit = ARGV[1]
  query = ARGV[2..]
end

folio.get_cql_json(path, limit || 10, query.join(' '))
