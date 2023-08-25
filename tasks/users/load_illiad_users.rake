# frozen_string_literal: true

require_relative '../helpers/illiad'
require_relative '../../lib/illiad_request'

namespace :illiad do
  include IlliadTaskHelpers

  desc 'fetch and load illiad users from folio'
  task :fetch_and_load_users do
    folio_json_users.each do |user|
      IlliadRequest.new.post('ILLiadWebPlatform/Users', illiad_user(JSON.parse(user)))
    end
  end
end
