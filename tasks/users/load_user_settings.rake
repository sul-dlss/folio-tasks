# frozen_string_literal: true

require 'csv'
require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'load user groups into folio'
  task :load_user_groups do
    groups_csv.each do |obj|
      groups_post(obj)
    end
  end

  # Using instead the default reference data address types
  # desc 'load address types into folio'
  # task :load_address_types do
  #   address_types_json['addressTypes'].each do |obj|
  #     address_types_post(obj)
  #   end
  # end

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

  desc 'load comment required settings into folio'
  task :load_comments do
    comments_json['comments'].each do |obj|
      comments_post(obj)
    end
  end

  desc 'load owners into folio'
  task :load_owners do
    owners_json['owners'].each do |obj|
      owners_post(obj)
    end
  end

  desc 'load manual charges into folio'
  task :load_manual_charges do
    manual_charges_json['feefines'].each do |obj|
      manual_charges_post(obj)
    end
  end

  desc 'load conditions into folio'
  task :load_conditions do
    conditions_json['patronBlockConditions'].each do |obj|
      conditions_put(obj['id'], obj)
    end
  end

  desc 'load patron blocks templates into folio'
  task :load_patron_blocks_templates do
    templates_json['manualBlockTemplates'].each do |obj|
      templates_post(obj)
    end
  end

  desc 'load limits into folio'
  task :load_limits do
    limits_json['patronBlockLimits'].each do |obj|
      limits_post(obj)
    end
  end
end
