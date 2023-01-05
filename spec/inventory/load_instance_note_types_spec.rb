# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'instance note types rake tasks' do
  let(:load_instance_note_types) { Rake.application.invoke_task 'inventory:load_instance_note_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/instance-note-types')
  end

  context 'when creating instance note types' do
    let(:instance_note_types_json) { load_instance_note_types.send(:instance_note_types_json) }

    it 'supplies valid json for loading instance note types' do
      expect(instance_note_types_json['instanceNoteTypes'].sample).to match_json_schema('mod-inventory-storage',
                                                                                        'instancenotetype')
    end
  end
end
