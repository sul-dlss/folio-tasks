# frozen_string_literal: true

require_relative '../helpers/configurations'
require_relative '../helpers/uuids/uuids'

namespace :configurations do
  include ConfigurationsTaskHelpers, Uuids

  desc 'delete configurations entries from folio'
  task :delete_config_entries do
    ids = Uuids.config_entries
    ids.each do |id|
      config_entry_delete(id)
    end
  end

  desc 'delete tenant addresses from folio'
  task :delete_tenant_addresses do
    ids = Uuids.tenant_addresses.values
    ids.each do |id|
      config_entry_delete(id)
    end
  end
end