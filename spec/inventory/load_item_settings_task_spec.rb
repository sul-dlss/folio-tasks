# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'item settings rake tasks' do
  let(:load_item_note_types_task) { Rake.application.invoke_task 'inventory:load_item_note_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/item-note-types')
  end

  context 'when loading item note types' do
    let(:item_note_types_csv) { load_item_note_types_task.send(:item_note_types_csv) }

    it 'creates the hash key and value for the item note name' do
      expect(load_item_note_types_task.send(:item_note_types_csv)[0]['name']).to eq 'Tech Staff'
    end

    it 'creates the hash key and value for the item note source' do
      expect(load_item_note_types_task.send(:item_note_types_csv)[0]['source']).to eq 'migration'
    end
  end
end
