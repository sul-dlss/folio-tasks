# frozen_string_literal: true

require_relative '../../lib/folio_request'

# Module to encapsulate folio request method
module FolioRequestHelper
  @@folio_request = FolioRequest.new

  def trim_hash(hash, name)
    hash[name].each do |obj|
      obj.delete('metadata')
      obj.delete('childOf')
      obj.delete('grantedTo')
      obj.delete('dummy')
      obj.delete('deprecated')
      obj.delete('authentication')
    end
    hash.delete('totalRecords')
    hash.delete('resultInfo')
    hash
  end

  def trim_default_data(hash, name)
    new_hash = []
    hash[name].each do |obj|
      next if obj['userInfo']['userName'] == 'System'

      obj.delete('childOf')
      obj.delete('grantedTo')
      obj.delete('dummy')
      obj.delete('deprecated')
      obj.delete('authentication')
      obj.delete('parentProfiles')
      obj.delete('childProfiles')
      new_hash.append(obj)
    end
    hash.delete('totalRecords')
    hash.delete('resultInfo')
    hash[name] = new_hash
  end
end
