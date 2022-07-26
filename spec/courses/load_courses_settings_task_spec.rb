# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'courses settings rake tasks' do
  let(:load_course_terms) { Rake.application.invoke_task 'courses:load_course_terms' }
  let(:load_course_depts) { Rake.application.invoke_task 'courses:load_course_depts' }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/coursereserves/terms')
    stub_request(:post, 'http://example.com/coursereserves/departments')
  end

  context 'when creating course terms' do
    let(:course_terms_json) { load_course_terms.send(:course_terms_json) }

    it 'supplies valid json for posting course terms' do
      expect(course_terms_json['terms'].sample).to match_json_schema('mod-courses', 'term')
    end
  end

  context 'when creating departments' do
    let(:course_depts_json) { load_course_depts.send(:course_depts_json) }

    it 'supplies valid json for posting course departments' do
      expect(course_depts_json['departments'].sample).to match_json_schema('mod-courses', 'department')
    end
  end
end
