# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'prepare order yaml files' do
  let(:sul_data_dir) { Settings.yaml.sul_orders.to_s }
  let(:law_data_dir) { Settings.yaml.law_orders.to_s }
  let(:fixture_data) { Settings.yaml.fixtures.to_s }

  before do
    Rake.application.invoke_task 'orders:create_sul_orders_yaml'
    Rake.application.invoke_task 'orders:add_sul_order_xinfo'
    Rake.application.invoke_task 'orders:add_sul_orderlin1_xinfo'
    Rake.application.invoke_task 'orders:add_sul_orderline_xinfo'
    Rake.application.invoke_task 'orders:create_law_orders_yaml'
    Rake.application.invoke_task 'orders:add_law_order_xinfo'
    Rake.application.invoke_task 'orders:add_law_orderlin1_xinfo'
    Rake.application.invoke_task 'orders:add_law_orderline_xinfo'
  end

  context 'when order has one orderline and one fund distribution' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/444444F21.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/444444F21.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has one orderline and split funding by amount' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/333333F22.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/333333F22.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has one orderline with split funding by percentage' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/222222F22.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/222222F22.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has multiple orderlines with one fund distribution' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/1ABC0000.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/1ABC0000.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has multiple orderlines with multiple fund distributions' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/555555F12.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/555555F12.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has order xinfo that maps to a tag' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/666666F07.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/666666F07.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has no orderline xinfo notes' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/1234L11.yaml")
      test_output = YAML.load_file("#{law_data_dir}/1234L11.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order has order and orderline xinfo notes' do
    it 'creates a yaml file' do
      fixture_file = YAML.load_file("#{fixture_data}/56789L02.yaml")
      test_output = YAML.load_file("#{law_data_dir}/56789L02.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when order ID has a forward-slash' do
    it 'creates a yaml file with underscore' do
      fixture_file = YAML.load_file("#{fixture_data}/VENDOR_GBP-SH.yaml")
      test_output = YAML.load_file("#{sul_data_dir}/VENDOR_GBP-SH.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  it 'creates a yaml file for SO-COMBO order type' do
    fixture_file = YAML.load_file("#{fixture_data}/777777F02.yaml")
    test_output = YAML.load_file("#{sul_data_dir}/777777F02.yaml")
    expect(test_output).to eq(fixture_file)
  end

  it 'creates a yaml file for SUBSCRIPT order type' do
    fixture_file = YAML.load_file("#{fixture_data}/888888F07.yaml")
    test_output = YAML.load_file("#{sul_data_dir}/888888F07.yaml")
    expect(test_output).to eq(fixture_file)
  end

  it 'creates a yaml file for GIFTSER order type' do
    fixture_file = YAML.load_file("#{fixture_data}/4321L04.yaml")
    test_output = YAML.load_file("#{law_data_dir}/4321L04.yaml")
    expect(test_output).to eq(fixture_file)
  end

  context 'when LAW order has BIGDEAL order xinfo notes' do
    it 'creates a yaml file with BIGDEAL mapped to notes' do
      fixture_file = YAML.load_file("#{fixture_data}/34567L22.yaml")
      test_output = YAML.load_file("#{law_data_dir}/34567L22.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end

  context 'when LAW order has duplicate orderline xinfo notes' do
    it 'creates a yaml file with duplicate notes removed' do
      fixture_file = YAML.load_file("#{fixture_data}/7890L09.yaml")
      test_output = YAML.load_file("#{law_data_dir}/7890L09.yaml")
      expect(test_output).to eq(fixture_file)
    end
  end
end
