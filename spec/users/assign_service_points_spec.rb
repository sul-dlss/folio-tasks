# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'assign default service point rake tasks' do
  let(:assign_service_points_task) { Rake.application.invoke_task 'tsv_users:assign_service_points' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/service-points')
      .with(query: hash_including)
      .to_return(body: '{
          "servicepoints": [
            { "id": "sp1Id", "code": "sp1" }
          ]
        }')

    stub_request(:get, 'http://example.com/request-preference-storage/request-preference')
      .with(query: hash_including)
      .to_return(body: '{
          "requestPreferences": [
            { "id": "requestPref1"}
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
  end

  context 'when assigning a default service point to a user' do
    before do
      stub_request(:put, 'http://example.com/request-preference-storage/request-preference/requestPref1')
        .with(body: '{"id":"requestPref1","defaultServicePointId":"sp1Id"}')
    end

    it 'user sunetId2 has service point sp2' do
      expect(assign_service_points_task.send(:user_acq_units_and_permission_sets_tsv)[1]['Service Point']).to eq 'sp2'
    end
  end
end
