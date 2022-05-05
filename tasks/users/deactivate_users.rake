# frozen_string_literal: true

require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'change an active user to inactive'
  task :deactivate_users do
    File.read(Settings.inactive_users_file).each_line do |line|
      data = line.split
      username = data[0]
      affiliation = data[1]
      size = 0
      user_hash = { 'users' => [], 'deactivateMissingUsers' => false, 'updateOnlyPresentFields' => true }
      user_get(username)['users'].each do |user|
        size += 1
        user_hash['users'] << inactive_user(user, affiliation)
      end
      user_hash['totalRecords'] = size
      user_update(user_hash)
    end
  end
end
