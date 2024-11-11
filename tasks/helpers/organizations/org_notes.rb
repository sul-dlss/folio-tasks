# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate org notes methods used by organizations rake tasks
module OrgNoteTaskHelpers
  include FolioRequestHelper

  def org_note_types_post
    @@folio_request.post('/note-types', '{"name": "Organization"}')
  end

  def org_note_type_id
    response = @@folio_request.get_cql('/note-types', 'name==Organization')['noteTypes']
    begin
      response[0]['id']
    rescue NoMethodError
      nil
    end
  end

  def org_notes_from_xml(xml_obj, org_id, note_type_id)
    notes = xml_obj.xpath('vendorExtendedInfo/entry').map do |note|
      note_hash(note_type_id, note&.text, org_id)
    end
    notes.compact
  end

  def note_hash(type_id, note, org_id)
    {
      'typeId' => type_id,
      'type' => 'Organization',
      'title' => 'Note',
      'domain' => 'organizations',
      'content' => note,
      'popUpOnCheckOut' => false,
      'popUpOnUser' => false,
      'links' => [{
        'id' => org_id,
        'type' => 'organization'
      }]
    }
  end

  def add_org_notes(xml_obj, org_id, note_type_id)
    org_notes_from_xml(xml_obj, org_id, note_type_id).each do |note_hash|
      next if note_hash.nil?

      org_notes_post(note_hash)
    end
  end

  def org_notes_post(obj)
    @@folio_request.post('/notes', obj.to_json)
  end
end
