# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'user settings rake tasks' do
  let(:load_user_groups_task) { Rake.application.invoke_task 'users:load_user_groups' }
  # let(:load_address_types_task) { Rake.application.invoke_task 'users:load_address_types' }
  let(:load_waivers_task) { Rake.application.invoke_task 'users:load_waivers' }
  let(:load_payments_task) { Rake.application.invoke_task 'users:load_payments' }
  let(:load_refunds_task) { Rake.application.invoke_task 'users:load_refunds' }
  let(:load_owners_task) { Rake.application.invoke_task 'users:load_owners' }
  let(:load_manual_charges_task) { Rake.application.invoke_task 'users:load_manual_charges' }
  let(:load_permission_sets_task) { Rake.application.invoke_task 'users:load_permission_sets' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/groups')
    stub_request(:post, 'http://example.com/addresstypes')
    stub_request(:post, 'http://example.com/waives')
    stub_request(:post, 'http://example.com/payments')
    stub_request(:post, 'http://example.com/refunds')
    stub_request(:post, 'http://example.com/owners')
    stub_request(:post, 'http://example.com/feefines')
    stub_request(:post, 'http://example.com/perms/permissions')
  end

  context 'when creating patron groups' do
    it 'creates the hash key and value for group name' do
      expect(load_user_groups_task.send(:groups_csv)[0]['group']).to eq 'GroupName'
    end

    it 'creates the hash key and value for the group description' do
      expect(load_user_groups_task.send(:groups_csv)[0]['desc']).to eq 'Group description'
    end
  end

  # Using instead the default reference data address types
  # context 'when creating address types' do
  #   let(:address_types_json) { load_address_types_task.send(:address_types_json) }

  #   it 'supplies valid json for posting address types' do
  #     expect(address_types_json['addressTypes'].sample).to match_json_schema('mod-users', 'addresstype')
  #   end
  # end

  context 'when creating waivers' do
    let(:waivers_json) { load_waivers_task.send(:waivers_json) }

    it 'supplies valid json for posting waivers' do
      expect(waivers_json['waivers'].sample).to match_json_schema('mod-feesfines', 'waivedata')
    end
  end

  context 'when creating payments' do
    let(:payments_json) { load_payments_task.send(:payments_json) }

    it 'supplies valid json for posting payments' do
      expect(payments_json['payments'].sample).to match_json_schema('mod-feesfines', 'paymentdata')
    end
  end

  context 'when creating refund reasons' do
    let(:refunds_json) { load_refunds_task.send(:refunds_json) }

    it 'supplies valid json for posting refunds' do
      expect(refunds_json['refunds'].sample).to match_json_schema('mod-feesfines', 'refunddata')
    end
  end

  context 'when creating fee_fine_owners' do
    let(:owners_json) { load_owners_task.send(:owners_json) }

    it 'supplies valid json for posting fee-fine owners' do
      expect(owners_json['owners'].sample).to match_json_schema('mod-feesfines', 'ownerdata')
    end
  end

  context 'when creating fee_fine_manual_charges' do
    let(:manual_charges_json) { load_manual_charges_task.send(:manual_charges_json) }

    it 'supplies valid json for posting fee-fine manual charges' do
      expect(manual_charges_json['feefines'].sample).to match_json_schema('mod-feesfines', 'feefinedata')
    end
  end

  context 'when creating permission sets' do
    let(:permission_sets_json) { load_permission_sets_task.send(:permission_sets_json) }

    it 'supplies valid json for poasting permission sets' do
      expect(permission_sets_json['permissions'].sample).to match_json_schema('mod-permissions', 'permissionUpload')
    end
  end
end
