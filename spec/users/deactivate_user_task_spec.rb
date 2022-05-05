# frozen_string_literal: true

require 'rake'
require 'spec_helper'

RSpec.configure do |config|
  config.before(:suite) do
    Dir.glob('tasks/helpers/users.rb').each { |r| Rake::DefaultLoader.new.load r }
  end
end

describe 'deactivate users rake tasks' do
  let(:found_user) { { 'username' => 'nschank', 'active' => true, 'patronGroup' => 'abc-123' } }
  let(:missing_user) { {} }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/groups/abc-123')
      .to_return(body: '{ "group": "Staff" }')
  end

  context 'when a user is found in folio' do
    it 'looks up the patron group from the /groups enpoint and replaces that in the user record' do
      result = UsersTaskHelpers.inactive_user(found_user, 'affiliate:sponsored')
      expect(result['patronGroup']).to eq 'Staff'
    end

    it 'changes the user to inactive' do
      result = UsersTaskHelpers.inactive_user(found_user, 'affiliate:sponsored')
      expect(result['active']).to be_falsey
    end

    it 'adds the custom affiliation field' do
      result = UsersTaskHelpers.inactive_user(found_user, 'affiliate:sponsored')
      expect(result['customFields']['affiliation']).to eq 'affiliate:sponsored'
    end
  end

  context 'when users are not found in folio' do
    it 'does not include the translated patronGroup' do
      result = UsersTaskHelpers.inactive_user(missing_user, 'affiliate:sponsored')
      expect(result['patronGroup']).to be_nil
    end
  end
end
