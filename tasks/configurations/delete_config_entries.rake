# frozen_string_literal: true

require_relative '../helpers/configurations'
require_relative '../helpers/uuids/uuids'

namespace :configurations do
  include ConfigurationsTaskHelpers, Uuids

  desc 'delete all okapi config entries from folio'
  task :delete_all_config_entries do
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

  desc 'delete email config'
  task :delete_email_config do
    email_config_get['smtpConfigurations'].each do |config|
      email_config_delete(config['id'])
    end
  end
end
