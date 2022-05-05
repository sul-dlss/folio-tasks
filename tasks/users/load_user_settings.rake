# frozen_string_literal: true

require 'csv'
require_relative '../../lib/folio_request'
require_relative '../helpers/users'

include UsersTaskHelpers

desc 'load user groups into folio'
task :load_user_groups do
  groups_csv.each do |obj|
    groups_post(obj)
  end
end

desc 'load address types into folio'
task :load_address_types do
  address_types_json['addressTypes'].each do |obj|
    address_types_post(obj)
  end
end

desc 'load waivers into folio'
task :load_waivers do
  waivers_json['waivers'].each do |obj|
    waivers_post(obj)
  end
end

desc 'load payment methods into folio'
task :load_payments do
  payments_json['payments'].each do |obj|
    payments_post(obj)
  end
end

desc 'load refund reasons into folio'
task :load_refunds do
  refunds_json['refunds'].each do |obj|
    refunds_post(obj)
  end
end

desc 'load fee-fine owners into folio'
task :load_fee_fine_owners do
  fee_fine_owners_json['owners'].each do |obj|
    fee_fine_owners_post(obj)
  end
end
