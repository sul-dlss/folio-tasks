# frozen_string_literal: true

require_relative 'helpers/inventory'
require_relative 'helpers/users'
require_relative 'helpers/data_import'
require_relative 'helpers/circulation'
require_relative 'helpers/courses'
require_relative 'helpers/configurations'

def open_file_and_pull(namespace, name, helper)
  scope = namespace.scope.path

  %i[json spec/fixtures/json].each do |dir|
    File.open("#{dir}/#{scope}/#{name}.json", 'w') { |file| file.puts helper.send("pull_#{name}") }
  end
end

namespace :inventory do |namespace|
  helper = InventoryTaskHelpers

  desc 'pull statistical codes types and codes from original folio instance (use STAGE=orig yaml)'
  task :pull_statistical_codes_and_types do
    Rake::Task['inventory:pull_statistical_code_types'].invoke
    Rake::Task['inventory:pull_statistical_codes'].invoke
  end

  desc 'pull statistical code types from original folio instance (use STAGE=orig yaml)'
  task :pull_statistical_code_types do
    name = 'statistical_code_types'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull statistical codes from original folio instance (use STAGE=orig yaml)'
  task :pull_statistical_codes do
    name = 'statistical_codes'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull instance note types from original folio instance (use STAGE=orig yaml)'
  task :pull_instance_note_types do
    name = 'instance_note_types'
    open_file_and_pull(namespace, name, helper)
  end
end

namespace :users do |namespace|
  helper = UsersTaskHelpers

  desc 'pull waivers from original folio instance (use STAGE=orig yaml)'
  task :pull_waivers do
    name = 'waivers'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull refunds from original folio instance (use STAGE=orig yaml)'
  task :pull_refunds do
    name = 'refunds'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull fee-fine owners from original folio instance (use STAGE=orig yaml)'
  task :pull_owners do
    name = 'owners'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull payments from original folio instance (use STAGE=orig yaml)'
  task :pull_payments do
    name = 'payments'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull manual charges from original folio instance (use STAGE=orig yaml)'
  task :pull_manual_charges do
    name = 'manual_charges'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull patron block conditions from original folio instance (use STAGE=orig yaml)'
  task :pull_conditions do
    name = 'conditions'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull patron block templates from original folio instance (use STAGE=orig yaml)'
  task :pull_patron_blocks_templates do
    name = 'templates'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull patron block limits from original folio instance (use STAGE=orig yaml)'
  task :pull_limits do
    name = 'limits'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull permission sets from original folio instance (use STAGE=orig yaml)'
  task :pull_permission_sets do
    name = 'permission_sets'
    open_file_and_pull(namespace, name, helper)
  end
end

namespace :data_import do |namespace|
  helper = DataImportTaskHelpers

  desc 'pull actionProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_action_profiles do
    name = 'action_profiles'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull jobProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_job_profiles do
    name = 'job_profiles'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull mappingProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_mapping_profiles do
    name = 'mapping_profiles'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull matchProfiles from original folio instance (use STAGE=orig yaml)'
  task :pull_match_profiles do
    name = 'match_profiles'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull_profile_associations'
  task :pull_profile_associations do
    %i[json spec/fixtures/json].each do |dir|
      File.open("#{dir}/data-import-profiles/profileAssociations.json", 'w') do |file|
        file.puts pull_profile_associations
      end
    end
  end
end

namespace :circulation do |namespace|
  helper = CirculationTaskHelpers

  desc 'pull circulation rules from original folio instance (use STAGE=orig yaml)'
  task :pull_circ_rules do
    name = 'circ_rules'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull fixed due date schedule from original folio instance (use STAGE=orig yaml)'
  task :pull_fixed_due_date_sched do
    name = 'fixed_due_date_sched'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull loan policies from original folio instance (use STAGE=orig yaml)'
  task :pull_loan_policies do
    name = 'loan_policies'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull overdue fines policies from original folio instance (use STAGE=orig yaml)'
  task :pull_overdue_fines do
    name = 'overdue_fines'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull lost item fees policies from original folio instance (use STAGE=orig yaml)'
  task :pull_lost_item_fees do
    name = 'lost_item_fees'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull patron notice policies from original folio instance (use STAGE=orig yaml)'
  task :pull_patron_notice_policies do
    name = 'patron_notice_policies'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull patron notice templates from original folio instance (use STAGE=orig yaml)'
  task :pull_patron_notice_templates do
    name = 'patron_notice_templates'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull request cancellation reasons from original folio instance (use STAGE=orig yaml)'
  task :pull_request_cancellation_reasons do
    name = 'request_cancellation_reasons'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull request policies from original folio instance (use STAGE=orig yaml)'
  task :pull_request_policies do
    name = ''
    open_file_and_pull(namespace, name, helper)
  end
end

namespace :courses do |namespace|
  helper = CoursesTaskHelpers

  desc 'pull course terms from original folio instance (use STAGE=orig yaml)'
  task :pull_course_terms do
    name = 'course_terms'
    open_file_and_pull(namespace, name, helper)
  end

  desc 'pull request policies from original folio instance (use STAGE=orig yaml)'
  task :pull_course_depts do
    name = 'course_depts'
    open_file_and_pull(namespace, name, helper)
  end
end

namespace :configurations do
  include ConfigurationsTaskHelpers

  desc 'pull module configurations'
  task :pull_configs do
    Settings.configurations.each do |config|
      File.open("#{Settings.json}/configurations/#{config}.json", 'w') do |file|
        file.puts pull_configurations(config.to_s)
      end
    end
  end

  desc 'pull configurations for modules specified in app config'
  task :pull_module_configs, [:module] do |_, args|
    File.open("#{Settings.json}/configurations/#{args[:module]}.json", 'w') do |file|
      file.puts pull_configurations(args[:module])
    end
  end
end
