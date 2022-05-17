# frozen_string_literal: true

require 'spec_helper'
require 'rake' # require rake because class is instantiated within a rake task
require_relative '../../lib/folio_uuid'

RSpec.describe FolioUuid do
  let(:okapi_url) { Settings.okapi.url.to_s }
  let(:folio_object_type) { 'instances' }
  let(:legacy_identifier) { 'a12345' }

  it 'creates a Folio UUID v5' do
    expect(described_class.new.generate(okapi_url, folio_object_type,
                                        legacy_identifier)).to eq 'ffc86e10-fe33-54e9-a882-e6f018a68b52'
  end
end
