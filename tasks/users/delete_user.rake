# frozen_string_literal: true

require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'delete user/perms/service-point-user from folio with username'
  task :delete_user, [:username] do |_, args|
    delete_user(args[:username])
  end
end
