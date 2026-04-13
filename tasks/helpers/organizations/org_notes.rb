# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate org notes methods used by organizations rake tasks
module OrgNoteTaskHelpers
  include FolioRequestHelper

  def org_note_types_post(obj)
    @@folio_request.post('/note-types', obj)
  end

  def org_notes_post(obj)
    @@folio_request.post('/notes', obj)
  end
end
