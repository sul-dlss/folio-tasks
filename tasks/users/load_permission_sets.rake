# frozen_string_literal: true

require 'csv'
require 'json'
require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'load permission sets into folio'
  task :load_permission_sets do
    display_name_sort(permission_sets_json['permissions'], 'displayName').each do |obj|
      permission_sets_post(obj)
    end
  end
end
