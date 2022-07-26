# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by course reserves settings rake tasks
module CoursesTaskHelpers
  include FolioRequestHelper

  def course_terms_json
    JSON.parse(File.read("#{Settings.json}/courses/terms.json"))
  end

  def course_terms_post(hash)
    @@folio_request.post('/coursereserves/terms', hash.to_json)
  end

  def course_depts_json
    JSON.parse(File.read("#{Settings.json}/courses/departments.json"))
  end

  def course_depts_post(hash)
    @@folio_request.post('/coursereserves/departments', hash.to_json)
  end

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
