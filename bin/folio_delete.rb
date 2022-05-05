# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
path = ARGV[0]
folio = FolioRequest.new
folio.delete(path)
