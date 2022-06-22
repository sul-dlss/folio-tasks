# frozen_string_literal: true

require_relative 'helpers/users'
require_relative 'helpers/data_import'

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
end
