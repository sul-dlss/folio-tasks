# frozen_string_literal: true

require 'uuidtools'

# Class to generate deterministic UUIDs using UUID version 5 (sha1)
class FolioUuid
  # based on https://github.com/FOLIO-FSE/folio_uuid python module
  def generate(okapi_url, folio_object_type, legacy_identifier)
    # namespace is the same for all "Folio UUIDs"
    @namespace = UUIDTools::UUID.parse('8405ae4d-b315-42e1-918a-d1919900cf3f')
    @name = [okapi_url, folio_object_type, legacy_identifier].join(':')

    UUIDTools::UUID.sha1_create(@namespace, @name).to_s
  end
end
