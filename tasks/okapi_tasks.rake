# frozen_string_literal: true

require 'csv'
require_relative 'helpers/okapi'

namespace :okapi do
  include OkapiTaskHelpers

  desc 'list okapi timers'
  task :list_timers do
    pp timers_get
  end

  desc 'disable circulation timers'
  task :disable_circulation_timers do
    disable_timers(circulation_timers)
  end

  desc 'enable circulation timers'
  task :enable_circulation_timers do
    enable_timers(circulation_timers)
  end

  desc 'disable piece claiming timer'
  task :disable_piece_claiming_timer do
    # we want to disable this timer bc it is broken https://folio-org.atlassian.net/browse/MODORDSTOR-434
    disable_timers(['mod-orders-storage_1'])
  end

  desc 'enable piece claiming timer'
  task :enable_piece_claiming_timer do
    enable_timers(['mod-orders-storage_1'])
  end

  desc 'disable all okapi timers'
  task :disable_timers do
    disable_timers(all_timers)
  end

  desc 'enable all okapi timers'
  task :enable_timers do
    enable_timers(all_timers)
  end
end
