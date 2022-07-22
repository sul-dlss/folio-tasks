# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'assign default service point rake tasks' do
  let(:assign_service_points_task) { Rake.application.invoke_task 'tsv_users:assign_service_points' }
  let(:user_service_point_data) { assign_service_points_task.send(:user_acq_units_and_permission_sets_tsv) }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, 'http://example.com/service-points')
      .with(query: hash_including)
      .to_return(body: '{
          "servicepoints": [{ "id": "sp1Id", "code": "sp1" },
                            { "id": "sp2Id", "code": "sp2" }]
        }')

    stub_request(:get, 'http://example.com/users')
      .with(query: hash_including)
      .to_return(body: '{
          "users": [{"id": "userId"}]
        }')

    stub_request(:post, 'http://example.com/service-points-users')
  end

  context 'when assigning a default service point to a user' do
    it 'has defaultServicePointId' do
      users = assign_service_points_task.send(:user_get, user_service_point_data[0]['SUNetID'])
      user_id = users['users'].first['id']
      service_point_id = Uuids.service_points[user_service_point_data[0]['Service Point']]
      expect(assign_service_points_task.send(:user_service_point_hash, user_id,
                                             service_point_id)['defaultServicePointId']).to eq 'sp1Id'
    end

    it 'user sunetId2 has service point sp2' do
      expect(user_service_point_data[1]['Service Point']).to eq 'sp2'
    end
  end
end
