# frozen_string_literal: true

require 'csv'
require_relative '../helpers/users'

namespace :users do
  include UsersTaskHelpers

  desc 'delete limits from folio'
  task :delete_limits do
    limits_json['patronBlockLimits'].each do |obj|
      puts "deleting #{obj['id']}"
      limits_delete(obj['id'])
    end
  end

  desc 'delete patron blocks templates from folio'
  task :delete_patron_blocks_templates do
    templates_json['manualBlockTemplates'].each do |obj|
      puts "deleting #{obj['id']}"
      templates_delete(obj['id'])
    end
  end

  desc 'delete manual charges from folio'
  task :delete_manual_charges do
    manual_charges_json['feefines'].each do |obj|
      puts "deleting #{obj['id']}"
      manual_charges_delete(obj['id'])
    end
  end

  desc 'delete refund reasons from folio'
  task :delete_refunds do
    refunds_json['refunds'].each do |obj|
      puts "deleting #{obj['id']}"
      refunds_delete(obj['id'])
    end
  end

  desc 'delete payment methods from folio'
  task :delete_payments do
    payments_json['payments'].each do |obj|
      puts "deleting #{obj['id']}"
      payments_delete(obj['id'])
    end
  end

  desc 'delete waivers from folio'
  task :delete_waivers do
    waivers_json['waivers'].each do |obj|
      puts "deleting #{obj['id']}"
      waivers_delete(obj['id'])
    end
  end

  desc 'delete owners from folio'
  task :delete_owners do
    owners_json['owners'].each do |obj|
      puts "deleting #{obj['id']}"
      owners_delete(obj['id'])
    end
  end
end
