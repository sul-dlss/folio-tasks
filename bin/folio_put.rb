# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'

folio = FolioRequest.new
path = folio.make_path(ARGV[0])
ARGV.length.positive? ? folio.put(path, ARGV[1]) : folio.put(path)
