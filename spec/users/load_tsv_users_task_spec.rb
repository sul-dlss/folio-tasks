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
  end

  it 'has a hash size that matches the number of lines in the tsv file' do
    expect(load_tsv_users_task.send(:tsv_user, grp)['users'].size).to eq 2
  end

  context 'when creating the new user hash' do
    it 'creates a hash with a username' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['username']).to eq '9999999999'
    end

    it 'creates a hash with a barcode' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['barcode']).to eq '9999999999'
    end

    it 'creates a hash with a patronGroup' do
      expect(load_tsv_users_task.send(:tsv_user, grp)['users'][0]['patronGroup']).to eq 'courtesy'
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
      expect(load_tsv_users_task.send(:tsv_user, grp)['totalRecords']).to eq 2
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
      expect(credentials['userId']).to eq '5ca62fbe-9528-5cc8-8abc-7f5bffc00a72'
    end

    it 'creates a hash without password' do
      expect(load_app_users_task.send(:app_user, app_user_data.first)).not_to have_key('password')
    end
  end
end
