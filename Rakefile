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
task load_tenant_settings: %i[tenant:load_institutions
                              tenant:load_campuses
                              tenant:load_libraries
                              tenant:load_service_points
                              tenant:load_locations
                              tenant:load_tenant_addresses]

desc 'Loads all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task load_finance_settings: %i[acquisitions:load_fund_types
                               acquisitions:load_expense_classes
                               acquisitions:load_fiscal_years
                               acquisitions:load_ledgers
                               acquisitions:load_finance_groups
                               acquisitions:load_funds
                               acquisitions:load_budgets]
desc 'Loads all organization settings and data: [organization categories, organizations for SUL, Business, and Law]'
task load_organizations_all: %i[acquisitions:load_org_categories
                                acquisitions:load_org_vendors_sul
                                acquisitions:load_org_vendors_business
                                acquisitions:load_org_vendors_law]
desc 'Delete all finance settings: [budgets, funds, finance_groups, ledgers, fiscal_years, fund_types, expense classes]'
task delete_finance_settings: %i[acquisitions:delete_budgets
                                 acquisitions:delete_funds
                                 acquisitions:delete_finance_groups
                                 acquisitions:delete_ledgers
                                 acquisitions:delete_fiscal_years
                                 acquisitions:delete_expense_classes
                                 acquisitions:delete_fund_types]
desc 'Delete all tenant settings: [addresses, locations, service_points, libraries, campuses, institutions]'
task delete_tenant_settings: %i[tenant:delete_tenant_addresses
                                tenant:delete_locations
                                tenant:delete_service_points
                                tenant:delete_libraries
                                tenant:delete_campuses
                                tenant:delete_institutions]

desc 'Load all user settings [groups, address_types, waivers, refunds]'
task load_user_settings: %i[load_user_groups load_address_types load_waivers load_refunds load_fee_fine_owners load_payments]

desc 'Loads all Acquisitions Units, Tenant, User and Finance settings'
task load_new_data_and_settings: %i[load_user_settings load_tenant_settings acquisitions:load_acq_units load_finance_settings load_organizations_all]

desc 'Prepare SUL order data'
task prepare_sul_orders: %i[acquisitions:create_sul_orders_yaml
                            acquisitions:add_sul_order_xinfo_to_yaml
                            acquisitions:add_sul_orderlin1_xinfo_to_yaml
                            acquisitions:add_sul_orderline_xinfo_to_yaml]

desc 'Prepare LAW order data'
task prepare_law_orders: %i[acquisitions:create_law_orders_yaml
                            acquisitions:add_law_order_xinfo_to_yaml
                            acquisitions:add_law_orderlin1_xinfo_to_yaml
                            acquisitions:add_law_orderline_xinfo_to_yaml]
