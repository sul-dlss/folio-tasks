# frozen_string_literal: true

require_relative '../helpers/circulation'

namespace :circulation do
  include CirculationTaskHelpers

  desc 'delete fixed due date schedules from folio'
  task :delete_fixed_due_date_sched do
    fixed_due_date_sched_json['fixedDueDateSchedules'].each do |obj|
      puts "deleting #{obj['id']}"
      fixed_due_date_sched_delete(obj['id'])
    end
  end

  desc 'delete loan policies from folio'
  task :delete_loan_policies do
    loan_policies_json['loanPolicies'].each do |obj|
      puts "deleting #{obj['id']}"
      loan_policies_delete(obj['id'])
    end
  end

  desc 'delete lost item fees policies from folio'
  task :delete_lost_item_fees do
    lost_item_fees_json['lostItemFeePolicies'].each do |obj|
      puts "deleting #{obj['id']}"
      lost_item_fees_delete(obj['id'])
    end
  end

  desc 'delete overdue fines policies from folio'
  task :delete_overdue_fines do
    overdue_fines_json['overdueFinePolicies'].each do |obj|
      puts "deleting #{obj['id']}"
      overdue_fines_delete(obj['id'])
    end
  end

  desc 'delete patron notice policies from folio'
  task :delete_patron_notice_policies do
    patron_notice_policies_json['patronNoticePolicies'].each do |obj|
      puts "deleting #{obj['id']}"
      patron_notice_policies_delete(obj['id'])
    end
  end

  desc 'delete patron notice templates from folio'
  task :delete_patron_notice_templates do
    patron_notice_templates_json['templates'].each do |obj|
      puts "deleting #{obj['id']}"
      patron_notice_templates_delete(obj['id'])
    end
  end

  desc 'delete request cancellation reasons from folio'
  task :delete_request_cancellation_reasons do
    request_cancellation_reasons_json['cancellationReasons'].each do |obj|
      puts "deleting #{obj['id']}"
      request_cancellation_reasons_delete(obj['id'])
    end
  end

  desc 'delete request policies from folio'
  task :delete_request_policies do
    request_policies_json['requestPolicies'].each do |obj|
      puts "deleting #{obj['id']}"
      request_policies_delete(obj['id'])
    end
  end
end
