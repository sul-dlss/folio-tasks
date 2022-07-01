# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by course reserves settings rake tasks
module CoursesTaskHelpers
  include FolioRequestHelper

  def pull_course_terms
    hash = @@folio_request.get('/coursereserves/terms')
    trim_hash(hash, 'terms')
    hash.to_json
  end

  def pull_course_depts
    hash = @@folio_request.get('/coursereserves/departments')
    trim_hash(hash, 'departments')
    hash.to_json
  end
end
