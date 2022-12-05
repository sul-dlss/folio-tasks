# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'material types rake tasks' do
  let(:load_material_types_task) { Rake.application.invoke_task 'inventory:load_material_types' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/material-types')
  end

  context 'when loading material types' do
    let(:material_types_csv) { load_material_types_task.send(:material_types_csv) }

    it 'creates the hash key and value for a material type name' do
      expect(load_material_types_task.send(:material_types_csv)[3]['name']).to eq 'accessories 4'
    end

    it 'creates the hash key and value for a material type id' do
      expect(load_material_types_task.send(:material_types_csv)[3]['id']).to eq '77d4dcd5-a0de-42c3-bd9d-627be43c391f'
    end

    it 'creates the hash key and value for a material type source' do
      expect(load_material_types_task.send(:material_types_csv)[3]['source']).to eq 'local'
    end
  end
end
