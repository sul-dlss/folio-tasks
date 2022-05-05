# frozen_string_literal: true

require 'csv'
require_relative '../../lib/folio_request'
require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'load permission sets into folio'
  task :load_permission_sets do
    permission_sets_json['permissions'].each do |obj|
      permission_sets_post(obj)
    end
  end
end
