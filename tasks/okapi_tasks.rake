# frozen_string_literal: true

require 'csv'
require_relative 'helpers/okapi'

namespace :okapi do
  include OkapiTaskHelpers

  desc 'disable circulation timers'
  task :disable_circulation_timers do
    disable_timers(circulation_timers)
  end

  desc 'enable circulation timers'
  task :enable_circulation_timers do
    enable_timers(circulation_timers)
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
