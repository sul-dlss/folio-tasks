# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by circ_settings rake tasks
module CirculationTaskHelpers
  include FolioRequestHelper

  def pull_circ_rules
    hash = @@folio_request.get('/circulation-rules-storage')
    hash.to_json
  end

  def pull_fixed_due_date_sched
    hash = @@folio_request.get('/fixed-due-date-schedule-storage/fixed-due-date-schedules')
    trim_hash(hash, 'fixedDueDateSchedules')
    hash.to_json
  end

  def pull_loan_policies
    hash = @@folio_request.get('/loan-policy-storage/loan-policies?limit=999')
    trim_hash(hash, 'loanPolicies')
    hash.to_json
  end

  def pull_overdue_fines
    hash = @@folio_request.get('/overdue-fines-policies?limit=100')
    trim_hash(hash, 'overdueFinePolicies')
    hash.to_json
  end

  def pull_lost_item_fees
    hash = @@folio_request.get('/lost-item-fees-policies?limit=100')
    trim_hash(hash, 'lostItemFeePolicies')
    hash.to_json
  end

  def pull_patron_notice_policies
    hash = @@folio_request.get('/patron-notice-policy-storage/patron-notice-policies?limit=100')
    trim_hash(hash, 'patronNoticePolicies')
    hash.to_json
  end

  def pull_patron_notice_templates
    # unclear what other templates this endpoint will return (not just patron notice templates)
    # currently only patron notice templates are created in test instance
    # might need to move to own, generic pull_templates method
    hash = @@folio_request.get_cql('/templates', 'active==true&limit=100')
    trim_hash(hash, 'templates')
    hash.to_json
  end

  def pull_request_cancellation_reasons
    hash = @@folio_request.get('/cancellation-reason-storage/cancellation-reasons')
    trim_hash(hash, 'cancellationReasons')
    hash.to_json
  end

  def pull_request_policies
    hash = @@folio_request.get('/request-policy-storage/request-policies')
    trim_hash(hash, 'requestPolicies')
    hash.to_json
  end
end
