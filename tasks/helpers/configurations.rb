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

  def config_entry_post(hash)
    @@folio_request.post('/configurations/entries', hash.to_json)
  end
end