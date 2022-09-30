# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by import_profiles rake tasks
# rubocop: disable Metrics/ModuleLength
module DataImportTaskHelpers
  include FolioRequestHelper

  def job_profiles_json
    JSON.parse(File.read("#{Settings.json}/data-import-profiles/jobProfiles.json"))
  end

  def job_profiles_post(obj)
    puts obj
    @@folio_request.post('/data-import-profiles/jobProfiles', obj.to_json)
  end

  def job_profiles_get(name)
    response = @@folio_request.get_cql('/data-import-profiles/jobProfiles', "name==#{name}")['jobProfiles']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def match_profiles_json
    JSON.parse(File.read("#{Settings.json}/data-import-profiles/matchProfiles.json"))
  end

  def match_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/matchProfiles', obj.to_json)
  end

  def match_profiles_get(name)
    response = @@folio_request.get_cql('/data-import-profiles/matchProfiles', "name==#{name}")['matchProfiles']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def action_profiles_json
    JSON.parse(File.read("#{Settings.json}/data-import-profiles/actionProfiles.json"))
  end

  def action_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/actionProfiles', obj.to_json)
  end

  def action_profiles_get(name)
    response = @@folio_request.get_cql('/data-import-profiles/actionProfiles', "name==#{name}")['actionProfiles']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def mapping_profiles_json
    JSON.parse(File.read("#{Settings.json}/data-import-profiles/mappingProfiles.json"))
  end

  def mapping_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/mappingProfiles', obj.to_json)
  end

  def mapping_profiles_get(name)
    response = @@folio_request.get_cql('/data-import-profiles/mappingProfiles', "name==#{name}")['mappingProfiles']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def import_profile_hash(obj)
    payload = {}
    payload['profile'] = obj
    payload
  end

  def profile_associations_ids(obj)
    name = CGI.escape(obj['name'])
    uuid = action_profiles_get(name)
    parent_name = parent_name(obj)
    parent_job_uuid = job_profiles_get(parent_name)
    parent_match_uuid = match_profiles_get(parent_name)
    child_name = child_name(obj)
    child_uuid = mapping_profiles_get(child_name)
    [uuid, parent_job_uuid, parent_match_uuid, child_uuid]
  end

  def parent_name(obj)
    return unless obj.dig('parentProfiles', 0, 'content')

    CGI.escape(obj['parentProfiles'][0]['content']['name'])
  end

  def child_name(obj)
    return unless obj.dig('childProfiles', 0)

    CGI.escape(obj['childProfiles'][0]['content']['name'])
  end

  def profile_associations_payload(master_id, master_type, detail_id, detail_type)
    order = detail_type.eql?('MAPPING_PROFILE') ? 0 : 1
    payload = {
      masterProfileId: master_id,
      masterProfileType: master_type,
      detailProfileId: detail_id,
      detailProfileType: detail_type,
      order: order
    }

    if master_id.nil?
      puts "HERE: #{payload}"
      return
    end

    payload
  end

  def profile_associations_post(payload, master, detail)
    @@folio_request.post("/data-import-profiles/profileAssociations?master=#{master}&detail=#{detail}",
                         payload.to_json)
  end

  def pull_action_profiles
    hash = @@folio_request.get('/data-import-profiles/actionProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'actionProfiles')
    remove_values(hash, 'userInfo')
    remove_values(hash, 'id')
    hash.to_json
  end

  def pull_job_profiles
    hash = @@folio_request.get('/data-import-profiles/jobProfiles?limit=999')
    trim_hash(hash, 'jobProfiles')
    remove_values(hash, 'userInfo')
    remove_values(hash, 'id')
    hash.to_json
  end

  def pull_mapping_profiles
    hash = @@folio_request.get('/data-import-profiles/mappingProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'mappingProfiles')
    remove_values(hash, 'userInfo')
    remove_values(hash, 'id')
    hash.to_json
  end

  def pull_match_profiles
    hash = @@folio_request.get('/data-import-profiles/matchProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'matchProfiles')
    remove_values(hash, 'userInfo')
    remove_values(hash, 'id')
    hash.to_json
  end

  def remove_values(hash, key_name)
    hash.each do |k, v|
      if k == key_name
        hash.delete(k)
      elsif v.is_a?(Hash)
        remove_values(v, key_name)
      elsif v.is_a?(Array)
        v.flatten.each { |x| remove_values(x, key_name) if x.is_a?(Hash) }
      end
    end
    hash
  end
end
# rubocop: enable Metrics/ModuleLength
