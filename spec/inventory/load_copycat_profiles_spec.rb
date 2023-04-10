# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'copy cataloging profiles rake tasks' do
  let(:load_copycat_profiles_task) { Rake.application.invoke_task 'inventory:load_copycat_profiles' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/copycat/profiles')
  end

  context 'when creating copy cataloging profiles' do
    let(:copycat_profiles_json) { load_copycat_profiles_task.send(:copycat_profiles_json) }

    it 'supplies valid json for loading copy cataloging profiles' do
      expect(copycat_profiles_json['profiles'].first).to match_json_schema('mod-copycat', 'copycatprofile')
    end

    it 'supplies valid json for loading copy cataloging profiles', skip: 'some profiles do not have updateJobProfileId and are valid' do
      expect(copycat_profiles_json['profiles'].sample).to match_json_schema('mod-copycat', 'copycatprofile')
    end
  end
end
