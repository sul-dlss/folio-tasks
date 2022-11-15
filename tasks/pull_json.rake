# frozen_string_literal: true

require_relative 'helpers/users'
require_relative 'helpers/data_import'
require_relative 'helpers/circulation'
require_relative 'helpers/courses'
require_relative 'helpers/configurations'

namespace :users do
  include UsersTaskHelpers

  json_files = %i[json spec/fixtures/json]

  desc 'pull waivers from original folio instance (use STAGE=orig yaml)'
  task :pull_waivers do
    json_files.each do |dir|
      File.open("#{dir}/users/waivers.json", 'w') { |file| file.puts pull_waivers }
    end
  end

  desc 'pull refunds from original folio instance (use STAGE=orig yaml)'
  task :pull_refunds do
    json_files.each do |dir|
      File.open("#{dir}/users/refunds.json", 'w') { |file| file.puts pull_refunds }
    end
  end

  desc 'pull fee-fine owners from original folio instance (use STAGE=orig yaml)'
  task :pull_owners do
    json_files.each do |dir|
      File.open("#{dir}/users/fee_fine_owners.json", 'w') { |file| file.puts pull_owners }
    end
  end

  desc 'pull payments from original folio instance (use STAGE=orig yaml)'
  task :pull_payments do
    json_files.each do |dir|
      File.open("#{dir}/users/payments.json", 'w') { |file| file.puts pull_payments }
    end
  end

  desc 'pull manual charges from original folio instance (use STAGE=orig yaml)'
  task :pull_manual_charges do
    json_files.each do |dir|
      File.open("#{dir}/users/fee_fine_manual_charges.json", 'w') { |file| file.puts pull_manual_charges }
    end
  end

  desc 'pull permission sets from original folio instance (use STAGE=orig yaml)'
  task :pull_permission_sets do
    json_files.each do |dir|
      File.open("#{dir}/users/permission_sets.json", 'w') { |file| file.puts pull_permission_sets }
    end
  end
end

namespace :data_import do
  include DataImportTaskHelpers

  json_files = %i[json spec/fixtures/json]

  desc 'pull actionProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_action_profiles do
    json_files.each do |dir|
      File.open("#{dir}/data-import-profiles/actionProfiles.json", 'w') { |file| file.puts pull_action_profiles }
    end
  end

  desc 'pull jobProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_job_profiles do
    json_files.each do |dir|
      File.open("#{dir}/data-import-profiles/jobProfiles.json", 'w') { |file| file.puts pull_job_profiles }
    end
  end

  desc 'pull mappingProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_mapping_profiles do
    json_files.each do |dir|
      File.open("#{dir}/data-import-profiles/mappingProfiles.json", 'w') { |file| file.puts pull_mapping_profiles }
    end
  end

  desc 'pull matchProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_match_profiles do
    json_files.each do |dir|
      File.open("#{dir}/data-import-profiles/matchProfiles.json", 'w') { |file| file.puts pull_match_profiles }
    end
  end

  desc 'pull_profile_associations'
  task :pull_profile_associations do
    json_files.each do |dir|
      File.open("#{dir}/data-import-profiles/profileAssociations.json", 'w') do |file|
        file.puts pull_profile_associations
      end
    end
  end
end

namespace :circulation do
  include CirculationTaskHelpers

  json_files = %i[json spec/fixtures/json]

  desc 'pull circulation rules from original folio instance (use STAGE=orig yaml)'
  task :pull_circ_rules do
    json_files.each do |dir|
      File.open("#{dir}/circulation/circulation-rules.json", 'w') { |file| file.puts pull_circ_rules }
    end
  end

  desc 'pull fixed due date schedule from original folio instance (use STAGE=orig yaml)'
  task :pull_fixed_due_date_sched do
    json_files.each do |dir|
      File.open("#{dir}/circulation/fixed-due-date-schedules.json", 'w') { |file| file.puts pull_fixed_due_date_sched }
    end
  end

  desc 'pull loan policies from original folio instance (use STAGE=orig yaml)'
  task :pull_loan_policies do
    json_files.each do |dir|
      File.open("#{dir}/circulation/loan-policies.json", 'w') { |file| file.puts pull_loan_policies }
    end
  end

  desc 'pull overdue fines policies from original folio instance (use STAGE=orig yaml)'
  task :pull_overdue_fines do
    json_files.each do |dir|
      File.open("#{dir}/circulation/overdue-fines-policies.json", 'w') { |file| file.puts pull_overdue_fines }
    end
  end

  desc 'pull lost item fees policies from original folio instance (use STAGE=orig yaml)'
  task :pull_lost_item_fees do
    json_files.each do |dir|
      File.open("#{dir}/circulation/lost-item-fees-policies.json", 'w') { |file| file.puts pull_lost_item_fees }
    end
  end

  desc 'pull patron notice policies from original folio instance (use STAGE=orig yaml)'
  task :pull_patron_notice_policies do
    json_files.each do |dir|
      File.open("#{dir}/circulation/patron-notice-policies.json", 'w') { |file| file.puts pull_patron_notice_policies }
    end
  end

  desc 'pull patron notice templates from original folio instance (use STAGE=orig yaml)'
  task :pull_patron_notice_templates do
    json_files.each do |dir|
      File.open("#{dir}/circulation/patron-notice-templates.json", 'w') do |file|
        file.puts pull_patron_notice_templates
      end
    end
  end

  desc 'pull request cancellation reasons from original folio instance (use STAGE=orig yaml)'
  task :pull_request_cancellation_reasons do
    json_files.each do |dir|
      File.open("#{dir}/circulation/cancellation-reasons.json", 'w') do |file|
        file.puts pull_request_cancellation_reasons
      end
    end
  end

  desc 'pull request policies from original folio instance (use STAGE=orig yaml)'
  task :pull_request_policies do
    json_files.each do |dir|
      File.open("#{dir}/circulation/request-policies.json", 'w') { |file| file.puts pull_request_policies }
    end
  end
end

namespace :courses do
  include CoursesTaskHelpers

  json_files = %i[json spec/fixtures/json]

  desc 'pull course terms from original folio instance (use STAGE=orig yaml)'
  task :pull_course_terms do
    json_files.each do |dir|
      File.open("#{dir}/courses/terms.json", 'w') { |file| file.puts pull_course_terms }
    end
  end

  desc 'pull request policies from original folio instance (use STAGE=orig yaml)'
  task :pull_course_depts do
    json_files.each do |dir|
      File.open("#{dir}/courses/departments.json", 'w') { |file| file.puts pull_course_depts }
    end
  end
end

namespace :configurations do
  include ConfigurationsTaskHelpers

  modules = %i[BULKEDIT CHECKOUT FAST_ADD ORG]

  desc 'pull module configurations'
  task :pull_configurations do
    modules.each do |config|
      File.open("json/configurations/#{config}.json", 'w') do |file|
        file.puts pull_configurations(config.to_s)
      end
    end
  end
end
