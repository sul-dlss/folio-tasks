# frozen_string_literal: true

require 'require_all'
require_rel '../helpers/organizations'

namespace :organizations do
  include InterfacesHelpers

  desc 'load interfaces into folio'
  task :load_interfaces do
    interfaces_json['interfaces'].each do |obj|
      interface_post(obj)
    end
  end

  desc 'load interface credentials into folio'
  task :load_credentials do
    credentials_json['credentials'].each do |obj|
      interface_id = obj['interfaceId']
      credential_post(interface_id, obj)
    end
  end
end
