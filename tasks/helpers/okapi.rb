# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by okapi rake tasks
module OkapiTaskHelpers
  include FolioRequestHelper

  def timers_get
    JSON.parse(@@folio_request.authenticated_request('/_/proxy/tenants/sul/timers'))
  end

  def timers_patch(json)
    response = @@folio_request.authenticated_request('/_/proxy/tenants/sul/timers', method: :patch, body: json)
    response.code
    response.body
  end

  def timer_id(timer_object)
    timer_object['id']
  end

  def disable_timers(timer_list)
    timer_list.each do |id|
      disable_hash = disable_timer(id)
      response = timers_patch(disable_hash.to_json)
      puts response
    end
  end

  def disable_timer(id)
    { 'id' => id, 'routingEntry' => { 'delay' => '0' } }
  end

  def enable_timers(timer_list)
    timer_list.each do |id|
      enable_hash = enable_timer(id)
      response = timers_patch(enable_hash.to_json)
      puts response
    end
  end

  def enable_timer(id)
    { 'id' => id, 'routingEntry' => {} }
  end

  def all_timers
    timers_get.map do |obj|
      timer_id(obj)
    end
  end

  def circulation_timers
    circ_timers = []
    timers_get.each do |obj|
      circ_id = timer_id(obj) if timer_id(obj).start_with?('mod-circulation_')
      circ_timers.push(circ_id).compact!
    end
    circ_timers
  end
end
