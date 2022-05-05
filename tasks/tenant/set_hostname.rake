# frozen_string_literal: true

require_relative '../../lib/folio_request'

desc 'set hostname for folio'
task :set_hostname do
  folio = FolioRequest.new
  hostname = Settings.folio.url
  payload = JSON.generate({ module: 'USERSBL',
                            configName: 'resetPassword',
                            code: 'FOLIO_HOST',
                            description: 'Folio UI application host',
                            default: true,
                            enabled: true,
                            value: hostname })
  folio.post('/configurations/entries', payload)
end
