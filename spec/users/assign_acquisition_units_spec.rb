# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'assign acquisition units rake tasks' do
  let(:assign_acquisition_units_task) { Rake.application.invoke_task 'tsv_users:assign_acquisition_units' }
  let(:acq_unit_hash) { AcquisitionsUuidsHelpers.acq_units }
  let(:membership_hash) { AcquisitionsUuidsHelpers.acq_unit_membership }
  let(:assign_acq_units) { assign_acquisition_units_task.send(:acq_units_assign, acq_unit_hash, membership_hash) }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/acquisitions-units/units')
      .to_return(body: '{
          "acquisitionsUnits": [
            { "id": "acquisitionsUnitId", "name": "acquisitionsUnitName" }
          ]
        }')

    stub_request(:get, 'http://example.com/acquisitions-units/memberships')
      .with(query: hash_including)
      .to_return(body: '{
          "acquisitionsUnitMemberships": [
            {
              "id": "membershipId",
              "userId": "userId",
              "acquisitionsUnitId": "acquisitionsUnitName"
            }
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

    stub_request(:post, 'http://example.com/acquisitions-units/memberships')
  end

  context 'when assigning a user to an existing acquisitions unit' do
    it 'has an array size that matches the number of lines in the tsv file' do
      expect(assign_acq_units.send(:user_acq_units_and_permission_sets_tsv).size).to eq 2
    end

    it 'has SUNetId of sunetId1' do
      expect(assign_acq_units.send(:user_acq_units_and_permission_sets_tsv)[0]['SUNetID']).to eq 'sunetId1'
    end

    it 'has Acq Unit assignment of acquisitionsUnitName' do
      expect(assign_acq_units.send(:user_acq_units_and_permission_sets_tsv)[0]['Acq Unit'])
        .to eq 'acquisitionsUnitName'
    end
  end

  context 'when assigning a user to a non-existent acquisitions unit' do
    it 'has SUNetId of sunetId2' do
      expect(assign_acq_units.send(:user_acq_units_and_permission_sets_tsv)[1]['SUNetID']).to eq 'sunetId2'
    end

    it 'has no Acq Unit assignment of missingAcquisitionsUnitName' do
      expect(assign_acq_units.send(:user_acq_units_and_permission_sets_tsv)[1]['Acq Unit'])
        .to eq 'missingAcquisitionsUnitName'
    end
  end
end
