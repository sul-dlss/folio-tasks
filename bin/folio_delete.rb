# frozen_string_literal: true

require_relative '../lib/folio_request'
require 'json'
folio = FolioRequest.new
path = folio.make_path(ARGV[0])
folio.delete(path)
