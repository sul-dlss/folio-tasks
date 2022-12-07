# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by circ_settings rake tasks
module CirculationTaskHelpers
  include FolioRequestHelper

  def circulation_rules_json
    JSON.parse(File.read("#{Settings.json}/circulation/circulation-rules.json"))
  end

  def circulation_rules_put(hash)
    @@folio_request.put('/circulation/rules', hash.to_json)
  end

  def fixed_due_date_sched_json
    JSON.parse(File.read("#{Settings.json}/circulation/fixed-due-date-schedules.json"))
  end

  def fixed_due_date_sched_post(hash)
    @@folio_request.post('/fixed-due-date-schedule-storage/fixed-due-date-schedules', hash.to_json)
  end

  def fixed_due_date_sched_delete(id)
    @@folio_request.delete("/fixed-due-date-schedule-storage/fixed-due-date-schedules/#{id}")
  end

  def loan_policies_json
    JSON.parse(File.read("#{Settings.json}/circulation/loan-policies.json"))
  end

  def loan_policies_post(hash)
    @@folio_request.post('/loan-policy-storage/loan-policies', hash.to_json)
  end

  def loan_policies_delete(id)
    @@folio_request.delete("/loan-policy-storage/loan-policies/#{id}")
  end

  def lost_item_fees_json
    JSON.parse(File.read("#{Settings.json}/circulation/lost-item-fees-policies.json"))
  end

  def lost_item_fees_post(hash)
    @@folio_request.post('/lost-item-fees-policies', hash.to_json)
  end

  def lost_item_fees_delete(id)
    @@folio_request.delete("/lost-item-fees-policies/#{id}")
  end

  def overdue_fines_json
    JSON.parse(File.read("#{Settings.json}/circulation/overdue-fines-policies.json"))
  end

  def overdue_fines_post(hash)
    @@folio_request.post('/overdue-fines-policies', hash.to_json)
  end

  def overdue_fines_delete(id)
    @@folio_request.delete("/overdue-fines-policies/#{id}")
  end

  def patron_notice_policies_json
    JSON.parse(File.read("#{Settings.json}/circulation/patron-notice-policies.json"))
  end

  def patron_notice_policies_post(hash)
    @@folio_request.post('/patron-notice-policy-storage/patron-notice-policies', hash.to_json)
  end

  def patron_notice_policies_delete(id)
    @@folio_request.delete("/patron-notice-policy-storage/patron-notice-policies/#{id}")
  end

  def patron_notice_templates_json
    JSON.parse(File.read("#{Settings.json}/circulation/patron-notice-templates.json"))
  end

  def patron_notice_templates_post(hash)
    @@folio_request.post('/templates', hash.to_json)
  end

  def patron_notice_templates_delete(id)
    @@folio_request.delete("/templates/#{id}")
  end

  def request_cancellation_reasons_json
    JSON.parse(File.read("#{Settings.json}/circulation/cancellation-reasons.json"))
  end

  def request_cancellation_reasons_post(hash)
    @@folio_request.post('/cancellation-reason-storage/cancellation-reasons', hash.to_json)
  end

  def request_cancellation_reasons_delete(id)
    @@folio_request.delete("/cancellation-reason-storage/cancellation-reasons/#{id}")
  end

  def request_policies_json
    JSON.parse(File.read("#{Settings.json}/circulation/request-policies.json"))
  end

  def request_policies_post(hash)
    @@folio_request.post('/request-policy-storage/request-policies', hash.to_json)
  end

  def request_policies_delete(id)
    @@folio_request.delete("/request-policy-storage/request-policies/#{id}")
  end

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
