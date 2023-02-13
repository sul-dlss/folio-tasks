# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'loading tsv users who do not have registry ids' do
  let(:load_tsv_users_task) { Rake.application.invoke_task 'tsv_users:load_tsv_users' }
  let(:grp) { load_tsv_users_task.send(:users_tsv, 'tsv_users.tsv') }
  let(:load_app_users_task) { Rake.application.invoke_task 'tsv_users:load_app_users' }
  let(:app_user_data) { load_app_users_task.send(:users_tsv, 'app_users.tsv') }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/user-import')
    stub_request(:post, 'http://example.com/users')
    stub_request(:post, 'http://example.com/authn/credentials')
    stub_request(:post, 'http://example.com/perms/users')

    stub_request(:get, 'http://example.com/groups')
      .with(query: hash_including)
      .to_return(body: '{ "usergroups": [ { "id": "abc-123" } ] }')
  end

  it 'has a hash size that matches the number of lines in the tsv file' do
    expect(load_tsv_users_task.send(:tsv_user, grp)['users'].size).to eq 4
  end

  context 'when creating the new user hash' do
    it 'creates a hash with a username' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['username']).to eq '9999999999'
    end

    it 'creates a hash with a barcode' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['barcode']).to eq '9999999999'
    end

    it 'creates a hash with a patronGroup' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][3]['patronGroup']).to eq 'courtesy'
    end

    it 'creates a hash with en enrollment date' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['enrollmentDate']).to eq '2004-07-31'
    end

    it 'creates a hash with an expiration date' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['expirationDate']).to eq '2099-07-31'
    end

    it 'creates a sub-hash with personal info last name' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['personal']['lastName']).to eq 'Reeve'
    end

    it 'creates a sub-hash with personal info middle name' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['personal']['middleName']).to eq 'D\'Olier'
    end

    it 'creates a sub-hash with personal info first name' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['personal']['firstName']).to eq 'Christopher'
    end

    it 'creates the usergroup custom field' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['customFields']['usergroup']).to eq 'Lecturer'
    end

    it 'has a totalRecords size in the hash' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['totalRecords']).to eq 4
    end

    it 'maps a user for BUS-guest' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][2]['patronGroup']).to eq 'BUS-guest'
    end

    it 'does not include a usergroup if mapping is not in settings config' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][3]['customFields']['usergroup']).to be_nil
    end
  end

  context 'when deleting the superceeded tsv data' do
    it 'removes the temporary fields' do
      %w[UNIV_ID NAME ADDR_LINE1 ADDR_LINE2 CITY STATE ZIP EMAIL PRIV_GRANTED PRIV_EXPIRED].each do |field|
        grp = load_tsv_users_task.send(:users_tsv, 'tsv_users.tsv')
        expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0][field]).to be_nil
      end
    end
  end

  context 'when creating an app user hash' do
    let(:credentials) { load_app_users_task.send(:app_user_credentials, app_user_data.first) }

    it 'creates a deterministic user id' do
      expect(credentials['userId']).to eq '948d87e6-96ff-5d6e-a1c6-e5af3805796f'
    end

    it 'creates a hash without password' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).not_to have_key('password')
    end
  end

  context 'when creating an app user without email or patronGroup' do
    it 'does not include email in the user data' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).not_to have_key('email')
    end

    it 'does not include patronGroup in the user data' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).to have_key('patronGroup')
    end
  end

  context 'when creating an app user with personal information' do
    it 'does not include email in the user data' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).not_to have_key('EMAIL')
    end

    it 'does not include patronGroup in the user data' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).not_to have_key('PATRON_GROUP')
    end

    it 'includes an email address if present' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['personal']).to have_key('email')
    end

    it 'includes a username' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['username']).to eq('access1')
    end

    it 'includes the active flag' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['active']).to be_truthy
    end

    it 'includes a first name' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['personal']).to have_key('firstName')
    end

    it 'includes a last name' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['personal']).to have_key('lastName')
    end

    it 'does not include a middle name' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['personal']).not_to have_key('middleName')
    end

    it 'does not include an address' do
      expect(TsvUserTaskHelpers.app_user(app_user_data[1])['personal']).not_to have_key('addresses')
    end
  end
end
