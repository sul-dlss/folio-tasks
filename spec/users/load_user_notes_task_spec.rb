# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'loading user notes and note types' do
  let(:load_user_note_types_task) { Rake.application.invoke_task 'tsv_users:load_user_note_types' }
  let(:load_user_notes_task) { Rake.application.invoke_task 'tsv_users:load_user_notes[circnote]' }
  let(:json_for_note) do
    '{"typeId":"1","type":"circnote","title":"CIRCNOTE NOTE","domain":"users",' \
      '"content":"This patron record should have a circnote",' \
      '"popUpOnCheckOut":false,"popUpOnUser":false,"links":[{"id":"abc-123","type":"user"}]}'
  end

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/note-types')
    stub_request(:get, 'http://example.com/note-types')
      .with(query: hash_including)
      .to_return(body: '{ "noteTypes": [{ "id": "1", "name": "circnote" }] }')
    stub_request(:post, 'http://example.com/notes')
    stub_request(:get, 'http://example.com/users')
      .with(query: hash_including)
      .to_return(body: '{ "users": [{ "id": "abc-123" }] }')
  end

  context 'when loading user note types' do
    it 'creates the hash key and value for a note type' do
      expect(load_user_note_types_task.send(:user_note_types)[0]['name']).to eq 'circnote'
    end
  end

  context 'when loading user notes of a particular type' do
    it 'posts a note of a given type to folio' do
      expect(load_user_notes_task.send(:user_notes, 'circnote')[0]['CIRCNOTE'])
        .to eq 'This patron record should have a circnote'
    end

    it 'construcs the note json for a user', skip: 'content of circnote is null; fix if using code again' do
      note = load_user_notes_task.send(:user_notes, 'circnote')[0]
      user = user_id(note.values[0])
      expect(load_user_notes_task.send(:note_json, %w[circnote 1], note, user)).to eq json_for_note
    end
  end
end
