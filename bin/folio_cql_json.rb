# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
require 'optparse'

options = { limit: 10 }

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} --path folio/API_path --limit (optional, default 10) --query 'cql,query,string' (i.e. use commas to conjoin query terms)"
  opts.on("-pAPI_PATH", "--path API_PATH", "FOLIO API path (REQUIRED)") { |p| options[:path] = p }
  opts.on("-lLIMIT", "--limit LIMIT", "The number of records to return (OPTIONAL)") { |l| options[:limit] = l }
  opts.on("-qQUERY", "--query QUERY", Array, "cql query, single-quote, comma-seperated (REQUIRED)") { |q| options[:query] = q }

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end

  if ARGV.length < 2
    puts opts
    exit
  end
end.parse!

folio = FolioRequest.new
path = folio.make_path(options[:path])
query = options[:query].join(' and ')

folio.get_cql_json(path, options[:limit], query)
