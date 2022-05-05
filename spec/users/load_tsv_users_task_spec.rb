# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'loading tsv users who do not have registry ids' do
  let(:load_tsv_users_task) { Rake.application.invoke_task 'load_tsv_users' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/user-import')
  end

  it 'has a hash size that matches the number of lines in the tsv file' do
    expect(load_tsv_users_task.send(:tsv_user)['users'].size).to eq 2
  end

  context 'when creating the new user hash' do
    it 'creates a hash with a username' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['username']).to eq '9999999999'
    end

    it 'creates a hash with a barcode' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['barcode']).to eq '9999999999'
    end

    it 'creates a hash with a patronGroup' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['patronGroup']).to eq 'Courtesy'
    end

    it 'creates a hash with en enrollment date' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['enrollmentDate']).to eq '2004-07-31'
    end

    it 'creates a hash with an expiration date' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['expirationDate']).to eq '2099-07-31'
    end

    it 'creates a sub-hash with personal info last name' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['personal']['lastName']).to eq 'Reeve'
    end

    it 'creates a sub-hash with personal info middle name' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['personal']['middleName']).to eq 'D\'Olier'
    end

    it 'creates a sub-hash with personal info first name' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['personal']['firstName']).to eq 'Christopher'
    end

    it 'creates the usergroup custom field' do
      expect(load_tsv_users_task.send(:tsv_user)['users'][0]['customFields']['usergroup']).to eq 'Lecturer'
    end

    it 'has a totalRecords size in the hash' do
      expect(load_tsv_users_task.send(:tsv_user)['totalRecords']).to eq 2
    end
  end

  context 'when deleting the superceeded tsv data' do
    it 'removes the temprary fields' do
      %w[UNIV_ID NAME ADDR_LINE1 ADDR_LINE2 CITY STATE ZIP EMAIL PRIV_GRANTED PRIV_EXPIRED].each do |field|
        expect(load_tsv_users_task.send(:tsv_user)['users'][0][field]).to be_nil
      end
    end
  end
end
