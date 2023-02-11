# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'load users from a tsv file: use file_name.tsv in tsv/users file'
  task :load_tsv_users_file, [:file] do |_, args|
    users_tsv(args[:file]).each_slice(500) do |group|
      user_update(tsv_user(group))
    end
  end

  desc 'load non-registry users from tsv file'
  task :load_tsv_users do
    users_tsv('tsv_users.tsv').each_slice(500) do |group|
      user_update(tsv_user(group))
    end
  end

  desc 'load expired users from tsv file'
  task :load_non_registry_users do
    users_tsv('non_reg_users.tsv').each_slice(500) do |group|
      user_update(tsv_user(group))
    end
  end

  desc 'load app users from tsv file'
  task :load_app_users do
    users_tsv('app_users.tsv').each do |user|
      user_login(app_user_credentials(user))
      user_post(app_user(user))
      puts 'Creating user record in permissions table'
      user_perms(app_user_id_hash(user))
    end
  end

  desc 'load user note types'
  task :load_user_note_types do
    user_note_types.each do |hash|
      FolioRequest.new.post('/note-types', hash.to_json)
    end
  end

  desc 'load user notes for a type'
  task :load_user_notes, [:type] do |_, args|
    type = Uuids.note_types.assoc(args[:type])
    user_notes(type[0]).each do |note|
      user = user_id(note.values[0])
      next if user.nil?

      user_notes_post(note_json(type, note, user))
    end
  end

  desc 'load all user note types and notes'
  task :load_all_user_notes_types do
    Rake::Task['tsv_users:load_user_note_types'].invoke
    task = Rake::Task['tsv_users:load_user_notes']
    user_note_types.each do |hash|
      type = hash['name']
      task.invoke(type)
      task.reenable
    end
  end
end
