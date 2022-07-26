# frozen_string_literal: true

require_relative '../helpers/circulation'

namespace :circulation do
  include CirculationTaskHelpers

  desc 'load fixed due date schedules into folio'
  task :load_fixed_due_date_sched do
    fixed_due_date_sched_json['fixedDueDateSchedules'].each do |obj|
      fixed_due_date_sched_post(obj)
    end
  end

  desc 'load loan policies into folio'
  task :load_loan_policies do
    loan_policies_json['loanPolicies'].each do |obj|
      loan_policies_post(obj)
    end
  end

  desc 'load lost item fees policies into folio'
  task :load_lost_item_fees do
    lost_item_fees_json['lostItemFeePolicies'].each do |obj|
      lost_item_fees_post(obj)
    end
  end

  desc 'load overdue fines policies into folio'
  task :load_overdue_fines do
    overdue_fines_json['overdueFinePolicies'].each do |obj|
      overdue_fines_post(obj)
    end
  end

  desc 'load patron notice policies into folio'
  task :load_patron_notice_policies do
    patron_notice_policies_json['patronNoticePolicies'].each do |obj|
      patron_notice_policies_post(obj)
    end
  end

  desc 'load patron notice templates into folio'
  task :load_patron_notice_templates do
    patron_notice_templates_json['templates'].each do |obj|
      patron_notice_templates_post(obj)
    end
  end

  desc 'load request cancellation reasons into folio'
  task :load_request_cancellation_reasons do
    request_cancellation_reasons_json['cancellationReasons'].each do |obj|
      request_cancellation_reasons_post(obj)
    end
  end

  desc 'load request policies into folio'
  task :load_request_policies do
    request_policies_json['requestPolicies'].each do |obj|
      request_policies_post(obj)
    end
  end
end
