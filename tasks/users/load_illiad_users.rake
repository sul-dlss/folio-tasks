# frozen_string_literal: true

require_relative '../helpers/illiad'
require_relative '../../lib/illiad_request'

namespace :illiad do
  include IlliadTaskHelpers

  desc 'fetch and load illiad users from folio'
  task :fetch_and_load_users, [:date] do |_, args|
    folio_json_users(args[:date]).each do |user|
      # skip unparseable log lines
      begin
        JSON.parse(user)
      rescue JSON::ParserError
        next
      end

      JSON.parse(user)['users'].each do |folio_user|
        ill_user = illiad_user(folio_user)
        puts IlliadRequest.new.post('ILLiadWebPlatform/Users', ill_user), ill_user
      end
    end
  end
end
