# frozen_string_literal: true

require_relative '../helpers/illiad'
require_relative '../../lib/illiad_request'

namespace :illiad do
  include IlliadTaskHelpers

  desc 'fetch and load illiad users from folio'
  task :fetch_and_load_users, [:date] do |_, args|
    folio_json_users(args[:date]).each do |user|
      JSON.parse(user)['users'].each do |folio_user|
        illiad_user = illiad_user(folio_user)
        illiad_response(
          IlliadRequest.new.post('ILLiadWebPlatform/Users', illiad_user), illiad_user
        )
      end
    end
  end
end
