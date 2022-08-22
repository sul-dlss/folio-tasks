# frozen_string_literal: true

require_relative '../../lib/folio_request'

desc 'set email configuration for folio'
task :set_email_config do
  folio = FolioRequest.new

  # These are the required fields for mod-email:
  configs = %w[host port username password from]

  configs.each do |opt|
    json = JSON.parse(File.read("#{Settings.json}/email/email_config_#{opt}.json")).to_json
    folio.post('/configurations/entries', json)
  end
end
