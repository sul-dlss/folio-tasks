# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  puts 'Unable to load RuboCop.'
end

# Import external rake tasks
Dir.glob('tasks/**/*.rake').each { |r| import r }

desc 'Loads all tenant settings: [institutions, campuses, libraries, service_points, locations, addresses]'
task load_tenant_settings: %i[tenant:load_institutions
                              tenant:load_campuses
                              tenant:load_libraries
                              tenant:load_service_points
                              tenant:load_locations]

desc 'Loads all finance settings: [fund_types, expense classes, fiscal_years, ledgers, finance_groups, funds, budgets, allocations]'
task load_finance_settings: %i[acquisitions:load_fund_types
                               acquisitions:load_expense_classes
                               acquisitions:load_fiscal_years
                               acquisitions:load_ledgers
                               acquisitions:load_finance_groups
                               acquisitions:load_funds
                               acquisitions:load_budgets
                               acquisitions:update_budgets
                               acquisitions:allocate_budgets]

desc 'Load all order settings: [acquisition methods]'
task load_order_settings: %i[acquisitions:load_acq_methods]

desc 'Loads all organization settings and data: [organization categories, SUL and Law migration error organizations, organizations for SUL, Business, and Law, and CORAL]'
task load_organizations_all: %i[acquisitions:load_org_categories
                                acquisitions:load_org_migrate_err
                                acquisitions:load_org_vendors_sul
                                acquisitions:load_org_vendors_business
                                acquisitions:load_org_vendors_law
                                acquisitions:load_org_coral]

desc 'Delete all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task delete_finance_settings: %i[acquisitions:delete_budgets
                                 acquisitions:delete_funds
                                 acquisitions:delete_finance_groups
                                 acquisitions:delete_ledgers
                                 acquisitions:delete_fiscal_years
                                 acquisitions:delete_expense_classes
                                 acquisitions:delete_fund_types]

desc 'Delete all tenant settings: [addresses, locations, service_points, libraries, campuses, institutions]'
task delete_tenant_settings: %i[tenant:delete_locations
                                tenant:delete_service_points
                                tenant:delete_libraries
                                tenant:delete_campuses
                                tenant:delete_institutions]

desc 'Load all user settings [groups, waivers, refunds, owners, manual charges, payments, patron block conditions, templates, and limits]'
task load_user_settings: %i[users:load_user_groups
                            users:load_waivers
                            users:load_refunds
                            users:load_owners
                            users:load_manual_charges
                            users:load_payments
                            users:load_conditions
                            users:load_patron_blocks_templates
                            users:load_limits]
      # users:load_address_types - now loaded by default reference data

desc 'Loads all Configurations, User, Tenant, Acquisitions Units, Finance, and Order Settings, and Organization settings and data'
task load_new_data_and_settings: %i[configurations:load_configs
                                    load_user_settings
                                    load_tenant_settings
                                    acquisitions:load_acq_units
                                    load_finance_settings
                                    load_order_settings
                                    load_organizations_all]

desc 'Process Symphony order data for SUL and LAW: [create yaml files, add xinfo fields to yaml, transform to folio orders]'
task prepare_orders: %i[acquisitions:create_sul_orders_yaml
                        acquisitions:add_sul_order_xinfo
                        acquisitions:add_sul_orderlin1_xinfo
                        acquisitions:add_sul_orderline_xinfo
                        acquisitions:transform_sul_orders
                        acquisitions:create_law_orders_yaml
                        acquisitions:add_law_order_xinfo
                        acquisitions:add_law_orderlin1_xinfo
                        acquisitions:add_law_orderline_xinfo
                        acquisitions:transform_law_orders]

desc 'Multi-thread load SUL and LAW order data with pool size and load SUL order tags'
task :load_orders, [:size] do |task, args|
  Rake::Task['acquisitions:load_tags_orders_sul'].invoke
  Rake::Task['acquisitions:load_sul_orders'].invoke args[:size]
  Rake::Task['acquisitions:load_law_orders'].invoke args[:size]
end

desc 'Pull all json data (use STAGE=orig)'
task pull_all_json_data: %i[users:pull_waivers
                            users:pull_refunds
                            users:pull_owners
                            users:pull_manual_charges
                            users:pull_payments
                            users:pull_conditions
                            users:pull_patron_blocks_templates
                            users:pull_limits
                            users:pull_permission_sets
                            data_import:pull_job_profiles
                            data_import:pull_mapping_profiles
                            data_import:pull_match_profiles
                            data_import:pull_action_profiles
                            data_import:pull_profile_associations
                            circulation:pull_circ_rules
                            circulation:pull_fixed_due_date_sched
                            circulation:pull_loan_policies
                            circulation:pull_overdue_fines
                            circulation:pull_lost_item_fees
                            circulation:pull_patron_notice_policies
                            circulation:pull_patron_notice_templates
                            circulation:pull_request_cancellation_reasons
                            circulation:pull_request_policies
                            configurations:pull_configs
                            courses:pull_course_terms
                            courses:pull_course_depts
                            inventory:pull_statistical_codes_and_types
                            inventory:pull_instance_note_types]

desc 'Pull all data import profile json data (use STAGE=orig)'
task pull_all_data_import_profiles_data: %i[data_import:pull_job_profiles
                                        data_import:pull_mapping_profiles
                                        data_import:pull_match_profiles
                                        data_import:pull_action_profiles
                                        data_import:pull_profile_associations]

desc 'Load all data import profiles [job, match, action, mapping, and associations]'
task load_all_data_import_profiles: %i[data_import:load_job_profiles
                                       data_import:load_match_profiles
                                       data_import:load_action_profiles
                                       data_import:load_mapping_profiles
                                       data_import:load_profile_associations]

desc 'Load all configurations [BULKEDIT CHECKOUT FAST_ADD INVOICE ORDERS ORG SMTP_SERVER TENANT USERSBL]'
task load_all_configurations: %i[configurations:load_configs]

desc 'Load all inventory settings: [alt title types, item loan types, item note types, material types, statistical codes, instance note types]'
task load_all_inventory_settings: %i[inventory:load_alt_title_types
                                     inventory:load_item_loan_types
                                     inventory:load_item_note_types
                                     inventory:load_material_types
                                     inventory:load_statistical_code_types
                                     inventory:load_statistical_codes
                                     inventory:load_instance_note_types]

desc 'Load all circulation settings: [fixed due date schedule, loan policies, lost item fee policies, overdue fines policies, patron notice policies, patron notice templates, request cancellation reasons, request policies, circ rules]'
task load_circ_settings: %i[circulation:load_fixed_due_date_sched
                            circulation:load_loan_policies
                            circulation:load_lost_item_fees
                            circulation:load_overdue_fines
                            circulation:load_patron_notice_policies
                            circulation:load_patron_notice_templates
                            circulation:load_request_cancellation_reasons
                            circulation:load_request_policies
                            circulation:load_circ_rules]

desc 'Delete all circulation settings'
task delete_circ_settings: %i[circulation:delete_request_policies
                              circulation:delete_request_cancellation_reasons
                              circulation:delete_patron_notice_templates
                              circulation:delete_patron_notice_policies
                              circulation:delete_overdue_fines
                              circulation:delete_lost_item_fees
                              circulation:delete_loan_policies
                              circulation:delete_fixed_due_date_sched]

desc 'Load all course reserve settings: [course terms, departments]'
task load_course_reserve_settings: %i[courses:load_course_terms
                                      courses:load_course_depts]
