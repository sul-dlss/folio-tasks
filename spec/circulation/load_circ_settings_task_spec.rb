# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'circ settings rake tasks' do
  let(:load_fixed_due_date_sched) { Rake.application.invoke_task 'circulation:load_fixed_due_date_sched' }
  let(:load_loan_policies) { Rake.application.invoke_task 'circulation:load_loan_policies' }
  let(:load_lost_item_fees) { Rake.application.invoke_task 'circulation:load_lost_item_fees' }
  let(:load_overdue_fines) { Rake.application.invoke_task 'circulation:load_overdue_fines' }
  let(:load_patron_notice_policies) { Rake.application.invoke_task 'circulation:load_patron_notice_policies' }
  let(:load_patron_notice_templates) { Rake.application.invoke_task 'circulation:load_patron_notice_templates' }
  let(:load_request_cancellation_reasons) do
    Rake.application.invoke_task 'circulation:load_request_cancellation_reasons'
  end
  let(:load_request_policies) { Rake.application.invoke_task 'circulation:load_request_policies' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/fixed-due-date-schedule-storage/fixed-due-date-schedules')
    stub_request(:post, 'http://example.com/loan-policy-storage/loan-policies')
    stub_request(:post, 'http://example.com/lost-item-fees-policies')
    stub_request(:post, 'http://example.com/overdue-fines-policies')
    stub_request(:post, 'http://example.com/patron-notice-policy-storage/patron-notice-policies')
    stub_request(:post, 'http://example.com/templates')
    stub_request(:post, 'http://example.com/cancellation-reason-storage/cancellation-reasons')
    stub_request(:post, 'http://example.com/request-policy-storage/request-policies')
  end

  context 'when creating fixed due date schedules' do
    let(:fixed_due_date_sched_json) { load_fixed_due_date_sched.send(:fixed_due_date_sched_json) }

    it 'supplies valid json for posting fixed due date schedules' do
      expect(fixed_due_date_sched_json['fixedDueDateSchedules'].sample).to match_json_schema(
        'mod-circulation-storage', 'fixed-due-date-schedule'
      )
    end
  end

  context 'when creating loan policies' do
    let(:loan_policies_json) { load_loan_policies.send(:loan_policies_json) }

    it 'supplies valid json for posting loan policies' do
      expect(loan_policies_json['loanPolicies'].sample).to match_json_schema('mod-circulation-storage', 'loan-policy')
    end
  end

  context 'when creating lost item fees policies' do
    let(:lost_item_fees_json) { load_lost_item_fees.send(:lost_item_fees_json) }

    it 'supplies valid json for posting lost item fees policies' do
      expect(lost_item_fees_json['lostItemFeePolicies'].sample).to match_json_schema('mod-feesfines',
                                                                                     'lost-item-fee-policy')
    end
  end

  context 'when creating overdue fines policies' do
    let(:overdue_fines_json) { load_overdue_fines.send(:overdue_fines_json) }

    it 'supplies valid json for posting overdue fines policies' do
      expect(overdue_fines_json['overdueFinePolicies'].sample).to match_json_schema('mod-feesfines',
                                                                                    'overdue-fine-policy')
    end
  end

  context 'when creating patron notice policies' do
    let(:patron_notice_policies_json) { load_patron_notice_policies.send(:patron_notice_policies_json) }

    it 'supplies valid json for posting patron notice policies' do
      expect(patron_notice_policies_json['patronNoticePolicies'].sample).to match_json_schema(
        'mod-circulation-storage', 'patron-notice-policy'
      )
    end
  end

  context 'when creating patron notice templates' do
    let(:patron_notice_templates_json) { load_patron_notice_templates.send(:patron_notice_templates_json) }

    it 'supplies valid json for posting patron notice templates' do
      expect(patron_notice_templates_json['templates'].sample).to match_json_schema('mod-template-engine', 'template')
    end
  end

  context 'when creating request cancellation reasons' do
    let(:request_cancellation_reasons_json) do
      load_request_cancellation_reasons.send(:request_cancellation_reasons_json)
    end

    it 'supplies valid json for posting request cancellation reasons' do
      expect(request_cancellation_reasons_json['cancellationReasons'].sample).to match_json_schema(
        'mod-circulation-storage', 'cancellation-reason'
      )
    end
  end

  context 'when creating request policies' do
    let(:request_policies_json) { load_request_policies.send(:request_policies_json) }

    it 'supplies valid json for posting request policies', skip: 'json is valid but schema validation is not working' do
      expect(request_policies_json['requestPolicies'].sample).to match_json_schema('mod-circulation-storage',
                                                                                   'request-policy')
    end
  end
end
