# frozen_string_literal: true

require_relative '../helpers/tsv_user'

namespace :tsv_users do
  include TsvUserTaskHelpers

  desc 'load users from tsv file'
  task :load_tsv_users do
    pp @user_hash
    user_update(@user_hash)
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
  task :load_all_user_note_types do
    task = Rake::Task['load_user_notes']
    user_note_types.each do |hash|
      type = hash['name']
      task.invoke(type)
      task.reenable
    end
  end
end
