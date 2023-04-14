# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'user settings rake tasks' do
  let(:load_user_groups_task) { Rake.application.invoke_task 'users:load_user_groups' }
  let(:load_user_custom_fields_task) { Rake.application.invoke_task 'users:load_user_custom_fields' }
  # let(:load_address_types_task) { Rake.application.invoke_task 'users:load_address_types' }
  let(:load_waivers_task) { Rake.application.invoke_task 'users:load_waivers' }
  let(:load_payments_task) { Rake.application.invoke_task 'users:load_payments' }
  let(:load_refunds_task) { Rake.application.invoke_task 'users:load_refunds' }
  let(:load_comments_task) { Rake.application.invoke_task 'users:load_comments' }
  let(:load_owners_task) { Rake.application.invoke_task 'users:load_owners' }
  let(:load_manual_charges_task) { Rake.application.invoke_task 'users:load_manual_charges' }
  let(:load_conditions_task) { Rake.application.invoke_task 'users:load_conditions' }
  let(:load_patron_blocks_templates_task) { Rake.application.invoke_task 'users:load_patron_blocks_templates' }
  let(:load_limits_task) { Rake.application.invoke_task 'users:load_limits' }
  let(:load_permission_sets_task) { Rake.application.invoke_task 'users:load_permission_sets' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/groups')
    stub_request(:put, 'http://example.com/custom-fields')
    stub_request(:post, 'http://example.com/addresstypes')
    stub_request(:post, 'http://example.com/waives')
    stub_request(:post, 'http://example.com/payments')
    stub_request(:post, 'http://example.com/refunds')
    stub_request(:post, 'http://example.com/comments')
    stub_request(:post, 'http://example.com/owners')
    stub_request(:post, 'http://example.com/feefines')
    stub_request(:put, %r{.*patron-block-conditions/.*})
    stub_request(:post, 'http://example.com/manual-block-templates')
    stub_request(:post, 'http://example.com/patron-block-limits')
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

  context 'when creating user custom fields' do
    let(:custom_fields_json) { UsersTaskHelpers.custom_fields_json }

    it 'has 5 custom fields' do
      expect(custom_fields_json['customFields'].length).to eq 5
    end
  end

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

  context 'when creating comment required settings' do
    let(:comments_json) { load_comments_task.send(:comments_json) }

    it 'supplies valid json for posting comment required settings' do
      expect(comments_json['comments'].sample).to match_json_schema('mod-feesfines', 'commentdata')
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

  context 'when loading patron block conditions' do
    let(:conditions_json) { load_conditions_task.send(:conditions_json) }

    it 'supplies valid json for putting patron block conditions' do
      expect(conditions_json['patronBlockConditions'].sample).to match_json_schema('mod-patron-blocks',
                                                                                   'patron-block-condition')
    end
  end

  context 'when loading patron block templates' do
    let(:templates_json) { load_patron_blocks_templates_task.send(:templates_json) }

    it 'supplies valid json for posting patron block templates' do
      expect(templates_json['manualBlockTemplates'].sample).to match_json_schema('mod-feesfines',
                                                                                 'manual-block-template')
    end
  end

  context 'when loading patron block limits' do
    let(:limits_json) { load_limits_task.send(:limits_json) }

    it 'supplies valid json for posting patron block templates' do
      expect(limits_json['patronBlockLimits'].sample).to match_json_schema('mod-patron-blocks', 'patron-block-limit')
    end
  end

  context 'when creating permission sets' do
    let(:permission_sets_json) { load_permission_sets_task.send(:permission_sets_json) }

    it 'supplies valid json for poasting permission sets' do
      expect(permission_sets_json['permissions'].sample).to match_json_schema('mod-permissions', 'permissionUpload')
    end

    it 'sorts the permission sets according to level' do
      UsersTaskHelpers.display_name_sort(permission_sets_json['permissions'], 'displayName').first(3).each do |obj|
        expect(obj['displayName'].index(/1/)).to be_truthy
      end
    end
  end
end
