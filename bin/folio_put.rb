# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'

folio = FolioRequest.new
path = folio.make_path(ARGV[0])
ARGV[1] && json = File.read(ARGV[1])
ARGV.length.positive? ? folio.put(path, json) : folio.put(path)
