# frozen_string_literal: true

require_relative 'folio_request'

# Module to encapsulate methods used by course reserves settings rake tasks
module CoursesTaskHelpers
  include FolioRequestHelper

  def course_terms_json
    JSON.parse(File.read("#{Settings.json}/courses/course_terms.json"))
  end

  def course_types_json
    JSON.parse(File.read("#{Settings.json}/courses/course_types.json"))
  end

  def course_terms_post(hash)
    @@folio_request.post('/coursereserves/terms', hash.to_json)
  end

  def course_types_post(hash)
    @@folio_request.post('/coursereserves/coursetypes', hash.to_json)
  end

  def course_depts_json
    JSON.parse(File.read("#{Settings.json}/courses/course_depts.json"))
  end

  def course_depts_post(hash)
    @@folio_request.post('/coursereserves/departments', hash.to_json)
  end

  def course_status_json
    JSON.parse(File.read("#{Settings.json}/courses/course_status.json"))
  end

  def course_status_post(hash)
    @@folio_request.post('/coursereserves/processingstatuses', hash.to_json)
  end

  def pull_course_terms
    hash = @@folio_request.get('/coursereserves/terms?limit=999')
    trim_hash(hash, 'terms')
    hash.to_json
  end

  def pull_course_types
    hash = @@folio_request.get('/coursereserves/coursetypes?limit=999')
    trim_hash(hash, 'courseTypes')
    hash.to_json
  end

  def pull_course_depts
    hash = @@folio_request.get('/coursereserves/departments?limit=999')
    trim_hash(hash, 'departments')
    hash.to_json
  end

  def pull_course_status
    hash = @@folio_request.get('/coursereserves/processingstatuses?limit=999')
    trim_hash(hash, 'processingStatuses')
    hash.to_json
  end
end
