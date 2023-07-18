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
                              tenant:load_locations
                              tenant:load_calendars]

desc 'Loads all finance settings that can be preloaded: [fund_types, expense classes, fiscal_years, ledgers, finance_groups]'
task load_finance_settings: %i[finance:load_fund_types
                               finance:load_expense_classes
                               finance:load_fiscal_years
                               finance:load_ledgers
                               finance:load_finance_groups]

desc 'Loads finance data: [funds and budgets]'
task load_finance_data: %i[finance:load_funds
                           finance:load_budgets]

desc 'Load all order settings: [acquisition methods]'
task load_order_settings: %i[orders:load_acq_methods]

desc 'Loads all organization settings and data: [organization categories, SUL and Law migration error organizations, organizations for SUL, Business, and Law, and CORAL]'
task load_organizations_all: %i[organizations:load_categories
                                organizations:load_interfaces
                                organizations:load_credentials
                                organizations:load_vendors_migrate_err
                                organizations:load_vendors_sul
                                organizations:load_vendors_business
                                organizations:load_vendors_law
                                organizations:load_coral]

desc 'Delete all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task delete_finance_settings: %i[finance:delete_budgets
                                 finance:delete_funds
                                 finance:delete_finance_groups
                                 finance:delete_ledgers
                                 finance:delete_fiscal_years
                                 finance:delete_expense_classes
                                 finance:delete_fund_types]

desc 'Delete all tenant settings: [addresses, locations, service_points, libraries, campuses, institutions]'
task delete_tenant_settings: %i[tenant:delete_locations
                                tenant:delete_service_points
                                tenant:delete_libraries
                                tenant:delete_campuses
                                tenant:delete_institutions]

desc 'Load all user settings [groups, waivers, refunds, comments, owners, manual charges, payments, patron block conditions, templates, and limits]'
task load_user_settings: %i[users:load_user_groups
                            users:load_waivers
                            users:load_refunds
                            users:load_comments
                            users:load_owners
                            users:load_manual_charges
                            users:load_payments
                            users:load_conditions
                            users:load_patron_blocks_templates
                            users:load_limits]
# users:load_address_types - now loaded by default reference data

desc 'Delete MOST user settings [limits, patron block templates, manual charges, refunds, comments, payments, waivers, and owners]'
task delete_user_settings: %i[users:delete_limits
                              users:delete_patron_blocks_templates
                              users:delete_manual_charges
                              users:delete_refunds
                              users:delete_comments
                              users:delete_payments
                              users:delete_waivers
                              users:delete_owners]

desc 'Loads all Configurations, User, Tenant, Acquisitions Units, Finance, and Order Settings, and Organization settings and data'
task load_new_data_and_settings: %i[configurations:load_configs
                                    load_user_settings
                                    load_tenant_settings
                                    load_acq_units
                                    load_finance_settings
                                    load_order_settings
                                    load_organizations_all]

desc 'Process Symphony order data for SUL and LAW: [create yaml files, add xinfo fields to yaml, transform to folio orders]'
task prepare_orders: %i[orders:create_sul_orders_yaml
                        orders:add_sul_order_xinfo
                        orders:add_sul_orderlin1_xinfo
                        orders:add_sul_orderline_xinfo
                        orders:transform_sul_orders
                        orders:create_law_orders_yaml
                        orders:add_law_order_xinfo
                        orders:add_law_orderlin1_xinfo
                        orders:add_law_orderline_xinfo
                        orders:transform_law_orders]

desc 'Load SUL order tags and load SUL and Law orders'
task :load_orders_and_tags do |_task|
  Rake::Task['orders:load_order_tags_sul'].invoke
  Rake::Task['orders:load_orders'].invoke('sul')
  Rake::Task['orders:load_orders'].reenable
  Rake::Task['orders:load_orders'].invoke('law')
end

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
                            users:pull_permission_sets
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
                            configurations:pull_configs
                            courses:pull_course_terms
                            courses:pull_course_depts
                            courses:pull_course_status
                            inventory:pull_statistical_codes_and_types
                            inventory:pull_instance_note_types
                            inventory:pull_copycat_profiles
                            organizations:pull_interfaces
                            organizations:pull_credentials
                            tenant:pull_calendars]

desc 'Pull all data import profile json data (use STAGE=orig)'
task pull_all_data_import_profiles_data: %i[data_import:pull_job_profiles
                                            data_import:pull_mapping_profiles
                                            data_import:pull_match_profiles
                                            data_import:pull_action_profiles
                                            data_import:pull_profile_associations]

desc 'Load all data import profiles [job, match, action, mapping, and associations]. To avoid duplicate associations, only run this task ONCE!'
task load_all_data_import_profiles: %i[data_import:load_job_profiles
                                       data_import:load_match_profiles
                                       data_import:load_action_profiles
                                       data_import:load_mapping_profiles
                                       data_import:load_profile_associations]

desc 'Load all configurations [edge-sip2 BULKEDIT CHECKOUT FAST_ADD LOAN_HISTORY CHECKOUT FAST_ADD INVOICE ORDERS ORG SETTINGS TENANT USERSBL] smtp_config and login'
task load_all_configurations: %i[configurations:load_configs
                                 configurations:load_email_config
                                 configurations:load_login_configs]

desc 'Load all inventory settings: [alt title types, item loan types, item note types, identifier types, material types, statistical codes, instance note types, holdings types, holding note types]'
task load_all_inventory_settings: %i[inventory:load_alt_title_types
                                     inventory:load_item_loan_types
                                     inventory:load_item_note_types
                                     inventory:load_identifier_types
                                     inventory:load_material_types
                                     inventory:load_statistical_code_types
                                     inventory:load_statistical_codes
                                     inventory:load_instance_note_types
                                     inventory:load_holdings_types
                                     inventory:load_holdings_note_types
                                     inventory:load_copycat_profiles]

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
                                      courses:load_course_types
                                      courses:load_course_depts
                                      courses:load_course_status]

desc 'Load app users and all permission sets'
task setup_app_users_and_psets: %i[tsv_users:load_app_users
                                   users:load_permission_sets
                                   tsv_users:assign_app_user_acq_units
                                   tsv_users:assign_app_user_psets
                                   tsv_users:assign_app_user_service_points]
