# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  puts 'Unable to load RuboCop.'
end

# Import external rake tasks
Dir.glob('tasks/**/*.rake').each { |r| import r }

desc 'Loads all tenant settings: [addresses, locations, service_points, libraries, campuses, institutions]'
task load_tenant_settings: %i[load_institutions
                              load_campuses
                              load_libraries
                              load_service_points
                              load_locations
                              load_tenant_addresses]

desc 'Loads all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task load_finance_settings: %i[load_fund_types
                               load_expense_classes
                               load_fiscal_years
                               load_ledgers
                               load_finance_groups
                               load_funds
                               load_budgets]
desc 'Loads all organization settings and data: [organization categories, organizations for SUL, Business, and Law]'
task load_organizations_all: %i[load_org_categories
                                load_org_vendors_sul
                                load_org_vendors_business
                                load_org_vendors_law]
desc 'Delete all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task delete_finance_settings: %i[delete_budgets
                                 delete_funds
                                 delete_finance_groups
                                 delete_ledgers
                                 delete_fiscal_years
                                 delete_expense_classes
                                 delete_fund_types]
desc 'Delete all tenant settings: [addresses, locations, service_points, libraries, campuses, institutions]'
task delete_tenant_settings: %i[delete_tenant_addresses
                                delete_locations
                                delete_service_points
                                delete_libraries
                                delete_campuses
                                delete_institutions]

desc 'Load all user settings [groups, address_types, waivers, refunds]'
task load_user_settings: %i[load_user_groups load_address_types load_waivers load_refunds load_fee_fine_owners load_payments]

desc 'Loads all Acquisitions Units, Tenant, User and Finance settings'
task load_new_data_and_settings: %i[load_user_settings load_tenant_settings load_acq_units load_finance_settings load_organizations_all]

desc 'Prepare SUL order data'
task prepare_sul_orders: %i[create_sul_orders_yaml add_sul_order_xinfo_to_yaml add_sul_orderlin1_xinfo_to_yaml add_sul_orderline_xinfo_to_yaml]

desc 'Prepare LAW order data'
task prepare_law_orders: %i[create_law_orders_yaml add_law_order_xinfo_to_yaml add_law_orderlin1_xinfo_to_yaml add_law_orderline_xinfo_to_yaml]
