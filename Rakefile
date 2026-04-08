# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  puts 'Unable to load RuboCop.'
end

# Import external rake tasks
Dir.glob('tasks/**/*.rake').each { |r| import r }

desc 'Pull all json data (use STAGE=orig)'
task pull_all_json_data: %i[users:pull_waivers
                            users:pull_refunds
                            users:pull_comments
                            users:pull_owners
                            users:pull_manual_charges
                            users:pull_payments
                            users:pull_conditions
                            users:pull_patron_blocks_templates
                            users:pull_limits
                            data_import:pull_job_profiles
                            data_import:pull_mapping_profiles
                            data_import:pull_match_profiles
                            data_import:pull_action_profiles
                            data_import:pull_profile_associations
                            data_import:pull_marc_bib_mappings
                            data_import:pull_marc_hold_mappings
                            circulation:pull_circ_rules
                            circulation:pull_fixed_due_date_sched
                            circulation:pull_loan_policies
                            circulation:pull_overdue_fines
                            circulation:pull_lost_item_fees
                            circulation:pull_patron_notice_policies
                            circulation:pull_patron_notice_templates
                            circulation:pull_request_cancellation_reasons
                            circulation:pull_request_policies
                            circulation:pull_staff_slips
                            configurations:pull_configs
                            configurations:pull_email_config
                            courses:pull_course_terms
                            courses:pull_course_types
                            courses:pull_course_depts
                            courses:pull_course_status
                            inventory:pull_statistical_codes_and_types
                            inventory:pull_instance_note_types
                            inventory:pull_copycat_profiles
                            organizations:pull_interfaces
                            organizations:pull_credentials
                            tenant:pull_calendars
                            tenant:pull_locations]
