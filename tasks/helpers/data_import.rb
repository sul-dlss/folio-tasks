# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by import_profiles rake tasks
module DataImportTaskHelpers
  include FolioRequestHelper

  def job_profiles_json
    profile = JSON.parse(File.read("#{Settings.json}/data-import-profiles/jobProfiles.json"))
    profile.delete('totalRecords')
    profile
  end

  def job_profiles_post(obj)
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

  def action_profiles_json
    profile = JSON.parse(File.read("#{Settings.json}/data-import-profiles/actionProfiles.json"))
    profile.delete('totalRecords')
    profile
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
    profile = JSON.parse(File.read("#{Settings.json}/data-import-profiles/mappingProfiles.json"))
    profile.delete('totalRecords')
    profile
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
    parent_name = CGI.escape(obj['parentProfiles'][0]['content']['name'])
    parent_uuid = job_profiles_get(parent_name)
    child_name = CGI.escape(obj['childProfiles'][0]['content']['name'])
    child_uuid = mapping_profiles_get(child_name)
    [uuid, parent_uuid, child_uuid]
  end

  def profile_associations_payload(master_id, master_type, detail_id, detail_type)
    order = detail_type.eql?('MAPPING_PROFILE') ? 0 : 1
    { masterProfileId: master_id,
      masterProfileType: master_type,
      detailProfileId: detail_id,
      detailProfileType: detail_type,
      order: order }
  end

  def profile_associations_post(payload, master, detail)
    @@folio_request.post("/data-import-profiles/profileAssociations?master=#{master}&detail=#{detail}",
                         payload.to_json)
  end

  def pull_action_profiles
    hash = @@folio_request.get('/data-import-profiles/actionProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'actionProfiles')
    remove_values(hash, 'userInfo')
    hash.to_json
  end

  def pull_job_profiles
    hash = @@folio_request.get('/data-import-profiles/jobProfiles?limit=999')
    trim_hash(hash, 'jobProfiles')
    remove_values(hash, 'userInfo')
    hash.to_json
  end

  def pull_mapping_profiles
    hash = @@folio_request.get('/data-import-profiles/mappingProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'mappingProfiles')
    remove_values(hash, 'userInfo')
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
