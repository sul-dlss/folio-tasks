# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load order tags rake tasks' do
  let(:load_order_tags_task) { Rake.application.invoke_task 'orders:load_order_tags_sul' }
  let(:sul_order_tags) { load_order_tags_task.send(:order_tags, 'order_xinfo_sul.tsv') }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/tags')
  end

  it 'has correctly formatted label' do
    tags = load_order_tags_task.send(:tag_hash, sul_order_tags[0])
    expect(tags).to include('label' => 'sulbigdeal:elsevier')
  end

  it 'has spaces replaced by underscores' do
    tags = load_order_tags_task.send(:tag_hash, sul_order_tags[1])
    expect(tags).to include('label' => 'suldata:hosted_by_vendor')
  end
end
