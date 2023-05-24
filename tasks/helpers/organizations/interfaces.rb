# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate organization interface methods
module InterfacesHelpers
  include FolioRequestHelper

  def pull_interfaces
    hash = @@folio_request.get('/organizations-storage/interfaces?limit=999')
    trim_hash(hash, 'interfaces')
    hash.to_json
  end

  def interfaces_json
    JSON.parse(File.read("#{Settings.json}/organizations/interfaces.json"))
  end

  def interface_post(hash)
    @@folio_request.post('/organizations-storage/interfaces', hash.to_json)
  end

  def pull_credentials
    credentials = { 'credentials' => [] }
    interfaces_json['interfaces'].each do |obj|
      credential = credential_get(obj['id'])
      credentials['credentials'].push(credential) unless credential.nil?
    end
    credentials.to_json
  end

  def credential_get(interface_id)
    @@folio_request.get("/organizations-storage/interfaces/#{interface_id}/credentials")
  end

  def credential_post(interface_id, hash)
    @@folio_request.post("/organizations-storage/interfaces/#{interface_id}/credentials", hash.to_json)
  end

  def credentials_json
    JSON.parse(File.read("#{Settings.json}/organizations/credentials.json"))
  end
end
