# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by configurations rake tasks
module ConfigurationsTaskHelpers
  include FolioRequestHelper

  def pull_configurations(config)
    hash = @@folio_request.get("/configurations/entries?query=module==#{config}&limit=50")
    trim_hash(hash, 'configs')
    hash.to_json
  end

  def config_entry_json(file)
    JSON.parse(File.read("#{Settings.json}/configurations/#{file}"))
  end

  def updated_config_entry_json(hash)
    email_host(hash) if hash['code'] == 'EMAIL_SMTP_HOST'
    hostname(hash) if hash['code'] == 'FOLIO_HOST'
    hash
  end

  def config_entry_post(hash)
    @@folio_request.post('/configurations/entries', hash.to_json)
  end

  def config_entry_put(hash)
    @@folio_request.put("/configurations/entries/#{hash['id']}", hash.to_json)
  end

  def config_entry_delete(id)
    @@folio_request.delete("/configurations/entries/#{id}")
  end

  def email_host(hash)
    hash['value'] = "mail.#{Settings.namespace}.svc.cluster.local"
  end

  def hostname(hash)
    hash['value'] = Settings.folio.url
  end
end
