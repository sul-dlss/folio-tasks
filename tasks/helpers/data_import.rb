# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by import_profiles rake tasks
module DataImportTaskHelpers
  include FolioRequestHelper

  def job_profiles_json
    JSON.parse(File.read("#{Settings.json}/data_import/job_profiles.json"))
  end

  def job_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/jobProfiles', obj.to_json)
  end

  def job_profiles_put(obj)
    @@folio_request.put("/data-import-profiles/jobProfiles/#{obj['profile']['id']}", obj.to_json)
  end

  def job_profiles_delete(id)
    @@folio_request.delete("/data-import-profiles/jobProfiles/#{id}", response_code: true)
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
    JSON.parse(File.read("#{Settings.json}/data_import/match_profiles.json"))
  end

  def match_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/matchProfiles', obj.to_json)
  end

  def match_profiles_put(obj)
    @@folio_request.put("/data-import-profiles/matchProfiles/#{obj['profile']['id']}", obj.to_json)
  end

  def match_profiles_delete(id)
    @@folio_request.delete("/data-import-profiles/matchProfiles/#{id}", response_code: true)
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
    JSON.parse(File.read("#{Settings.json}/data_import/action_profiles.json"))
  end

  def action_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/actionProfiles', obj.to_json)
  end

  def action_profiles_put(obj)
    @@folio_request.put("/data-import-profiles/actionProfiles/#{obj['profile']['id']}", obj.to_json)
  end

  def action_profiles_delete(id)
    @@folio_request.delete("/data-import-profiles/actionProfiles/#{id}", response_code: true)
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
    JSON.parse(File.read("#{Settings.json}/data_import/mapping_profiles.json"))
  end

  def mapping_profiles_post(obj)
    @@folio_request.post('/data-import-profiles/mappingProfiles', obj.to_json)
  end

  def mapping_profiles_put(obj)
    @@folio_request.put("/data-import-profiles/mappingProfiles/#{obj['profile']['id']}", obj.to_json)
  end

  def mapping_profiles_delete(id)
    @@folio_request.delete("/data-import-profiles/mappingProfiles/#{id}", response_code: true)
  end

  def mapping_profiles_get(name)
    response = @@folio_request.get_cql('/data-import-profiles/mappingProfiles', "name==#{name}")['mappingProfiles']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def profile_associations_json
    JSON.parse(File.read("#{Settings.json}/data_import/profile_associations.json"))
  end

  def import_profile_hash(obj)
    payload = {}
    payload['profile'] = obj
    payload
  end

  def profile_associations_post(payload, master, detail)
    @@folio_request.post("/data-import-profiles/profileAssociations?detail=#{detail}&master=#{master}",
                         payload.to_json)
  end

  def profile_associations_put(payload, master, detail)
    @@folio_request.put("/data-import-profiles/profileAssociations/#{payload['id']}?detail=#{detail}&master=#{master}",
                        payload.to_json)
  end

  def pull_action_profiles
    hash = @@folio_request.get('/data-import-profiles/actionProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'actionProfiles')
    remove_system_profiles(hash, 'actionProfiles')
    hash.to_json
  end

  def pull_job_profiles
    hash = @@folio_request.get('/data-import-profiles/jobProfiles?limit=999')
    trim_hash(hash, 'jobProfiles')
    remove_system_profiles(hash, 'jobProfiles')
    hash.to_json
  end

  def pull_mapping_profiles
    hash = @@folio_request.get('/data-import-profiles/mappingProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'mappingProfiles')
    remove_system_profiles(hash, 'mappingProfiles')
    hash.to_json
  end

  def pull_match_profiles
    hash = @@folio_request.get('/data-import-profiles/matchProfiles?withRelations=true&limit=999')
    trim_hash(hash, 'matchProfiles')
    remove_system_profiles(hash, 'matchProfiles')
    hash.to_json
  end

  def pull_profile_associations
    hash = { 'profileAssociations' => [] }
    master = %w[JOB ACTION MATCH]
    master.each do |profile_m|
      details = profile_m == 'ACTION' ? %w[ACTION MAPPING MATCH] : %w[ACTION MATCH]
      details.each do |profile_d|
        profile_associations = @@folio_request.get(
          "/data-import-profiles/profileAssociations?master=#{profile_m}_PROFILE&detail=#{profile_d}_PROFILE"
        )
        profile_associations['profileAssociations'].each do |obj|
          hash['profileAssociations'].append(obj) unless duplicate_association(hash, obj)
        end
      end
    end
    hash.to_json
  end

  def duplicate_association(hash, obj)
    duplicate_association = false
    hash['profileAssociations'].each do |assoc|
      (assoc.key(obj['masterProfileId']) &&
      assoc.key(obj['detailProfileId']) &&
      assoc.key(obj['masterProfileType']) &&
      assoc.key(obj['detailProfileType'])) && duplicate_association = true
    end
    duplicate_association
  end

  def pull_marc_bib_mappings
    hash = @@folio_request.get('/mapping-rules/marc-bib')
    hash.to_json
  end

  def pull_marc_hold_mappings
    hash = @@folio_request.get('/mapping-rules/marc-holdings')
    hash.to_json
  end

  def marc_bib_mapping_json
    JSON.parse(File.read("#{Settings.json}/data_import/marc_bib_mappings.json"))
  end

  def marc_bib_mapping_put(obj)
    @@folio_request.put('/mapping-rules/marc-bib', obj.to_json)
  end

  def marc_hold_mapping_json
    JSON.parse(File.read("#{Settings.json}/data_import/marc_hold_mappings.json"))
  end

  def marc_hold_mapping_put(obj)
    @@folio_request.put('/mapping-rules/marc-holdings', obj.to_json)
  end

  def profile_associations_load(payload, master, detail)
    uuids = profile_associations_ids

    if uuids.include?(payload['id'])
      profile_associations_put(payload, master, detail)
    else
      profile_associations_post(payload, master, detail)
    end
  end

  def remove_system_profiles(hash, name)
    new_hash = []
    hash[name].each do |obj|
      next if obj['userInfo']['userName'] == 'System'

      obj.delete('parentProfiles')
      obj.delete('childProfiles')
      obj.delete('userInfo')
      new_hash.append(obj)
    end
    hash[name] = new_hash
  end
end
