# frozen_string_literal: true

require_relative '../helpers/courses'

namespace :courses do
  include CoursesTaskHelpers

  desc 'load course terms into folio'
  task :load_course_terms do
    course_terms_json['terms'].each do |obj|
      course_terms_post(obj)
    end
  end

  desc 'load course departments into folio'
  task :load_course_depts do
    course_depts_json['departments'].each do |obj|
      course_depts_post(obj)
    end
  end

  desc 'load course processing statuses into folio'
  task :load_course_status do
    course_status_json['processingStatuses'].each do |obj|
      course_status_post(obj)
    end
  end
end
