# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'assign permission sets rake task' do
  let(:assign_permission_sets_task) { Rake.application.invoke_task 'tsv_users:assign_permission_sets' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/perms/permissions')
      .with(query: hash_including)
      .to_return(body: '{
          "permissions": [
            { "id": "psetId1", "displayName": "pset 1" },
            { "id": "psetId2", "displayName": "pset 2" }
          ]
        }')

    stub_request(:get, 'http://example.com/users')
      .with(query: hash_including)
      .to_return(body: '{
          "users": [
            {
              "id": "userId"
            }
          ]
        }')

    stub_request(:get, 'http://example.com/perms/users/userId/permissions')
      .with(query: hash_including)
      .to_return(body: '{
          "permissionNames": [
            { "permissionName": "permissionName1", "displayName": "pset 1", "mutable": false },
            { "permissionName": "permissionName2", "displayName": "pset 2", "mutable": true },
            { "permissionName": "permissionName3", "displayName": "unknown pset", "mutable": true }
          ]
        }')

    stub_request(:delete, 'http://example.com/perms/users/userId/permissions/permissionName2')
      .with(query: hash_including)
  end

  context 'when assigning a user an existing permission set' do
    before do
      stub_request(:post, 'http://example.com/perms/users/userId/permissions')
        .with(query: hash_including)
        .with(body: '{"permissionName":"psetId1"}')
    end

    it 'has a hash with keys of the columns in the tsv file' do
      expect(assign_permission_sets_task.send(:user_acq_units_and_permission_sets_tsv)[0].keys.size).to eq 5
    end

    it 'has SUNetId of sunetId1' do
      expect(assign_permission_sets_task.send(:user_acq_units_and_permission_sets_tsv)[0]['SUNetID']).to eq 'sunetId1'
    end

    it 'has permission set assignment of pset 1' do
      expect(assign_permission_sets_task.send(:user_acq_units_and_permission_sets_tsv)[0]['pset 1'])
        .to eq 'yes'
    end
  end

  context 'when assigning a user to a non-existent permission set' do
    it 'has SUNetId of sunetId2' do
      expect(assign_permission_sets_task.send(:user_acq_units_and_permission_sets_tsv)[1]['SUNetID']).to eq 'sunetId2'
    end

    it 'has no permission set assignment even though pset 3 marked as "yes"' do
      expect(assign_permission_sets_task.send(:user_acq_units_and_permission_sets_tsv)[1]['pset 3'])
        .to eq 'yes'
    end
  end
end
