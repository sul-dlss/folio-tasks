# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'load orders tags rake tasks' do
  let(:load_sul_order_tags_task) { Rake.application.invoke_task 'acquisitions:load_tags_orders_sul' }
  let(:sul_order_tags) { load_sul_order_tags_task.send(:order_tags, 'order_xinfo_sul.tsv') }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:post, 'http://example.com/tags')
  end

  it 'has correctly formatted label' do
    tags = load_sul_order_tags_task.send(:tag_hash, sul_order_tags[0])
    expect(tags).to include('label' => 'SULBIGDEAL:Elsevier')
  end

  it 'has spaces replaced by underscores' do
    tags = load_sul_order_tags_task.send(:tag_hash, sul_order_tags[1])
    expect(tags).to include('label' => 'SULDATA:Hosted_by_vendor')
  end
end
