# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
path = ARGV[0]
folio = FolioRequest.new
ARGV.length.positive? ? folio.put(path, ARGV[1]) : folio.put(path)
