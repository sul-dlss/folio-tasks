# frozen_string_literal: true

require 'require_all'
require_rel '../helpers/orders'

namespace :orders do
  include OrderYamlTaskHelpers

  desc 'process Symphony orders for SUL'
  task :create_sul_orders_yaml do
    data_dir = Settings.yaml.sul_orders.to_s
    orders_tsv('orders_sul.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      if File.exist?(filename)
        yaml_hash = YAML.load_file(filename)
        new_data = modify_order_data(obj, yaml_hash)
        modify_yaml_file(new_data, filename) unless new_data.nil?
      else
        puts "writing #{filename}"
        write_yaml_file(obj, filename)
      end
    end
  end

  desc 'add order xinfo fields to order yaml files'
  task :add_sul_order_xinfo do
    data_dir = Settings.yaml.sul_orders.to_s
    orders_tsv('order_xinfo_sul.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_order_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'add orderline 1 xinfo fields to order yaml files'
  task :add_sul_orderlin1_xinfo do
    data_dir = Settings.yaml.sul_orders.to_s
    orders_tsv('orderlin1_xinfo_sul.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_orderlin1_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'add orderline xinfo fields to order yaml files'
  task :add_sul_orderline_xinfo do
    data_dir = Settings.yaml.sul_orders.to_s
    orders_tsv('orderlin_xinfo_sul.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_orderline_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'process Symphony orders for LAW'
  task :create_law_orders_yaml do
    data_dir = Settings.yaml.law_orders.to_s
    orders_tsv('orders_law.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      if File.exist?(filename)
        yaml_hash = YAML.load_file(filename)
        new_data = modify_order_data(obj, yaml_hash)
        puts "updating #{filename}"
        modify_yaml_file(new_data, filename) unless new_data.nil?
      else
        puts "writing #{filename}"
        write_yaml_file(obj, filename)
      end
    end
  end

  desc 'add order xinfo fields to order yaml files'
  task :add_law_order_xinfo do
    data_dir = Settings.yaml.law_orders.to_s
    orders_tsv('order_xinfo_law.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_order_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'add orderline 1 xinfo fields to order yaml files'
  task :add_law_orderlin1_xinfo do
    data_dir = Settings.yaml.law_orders.to_s
    orders_tsv('orderlin1_xinfo_law.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_orderlin1_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'add orderline xinfo fields to order yaml files'
  task :add_law_orderline_xinfo do
    data_dir = Settings.yaml.law_orders.to_s
    orders_tsv('orderlin_xinfo_law.tsv').each do |obj|
      filename = "#{data_dir}/#{obj['ORD_ID'].to_s.tr('/', '_')}.yaml"
      next unless File.exist?(filename)

      yaml_hash = YAML.load_file(filename)
      new_data = add_orderline_xinfo(obj, yaml_hash)
      puts "updating #{filename}"
      modify_yaml_file(new_data, filename) unless new_data.nil?
    end
  end

  desc 'delete sul order yaml files'
  task :delete_sul_order_yaml do
    data_dir = Settings.yaml.sul_orders.to_s
    Dir.each_child(data_dir) { |i| File.delete("#{data_dir}/#{i}") }
  end

  desc 'delete law order yaml files'
  task :delete_law_order_yaml do
    data_dir = Settings.yaml.law_orders.to_s
    Dir.each_child(data_dir) { |i| File.delete("#{data_dir}/#{i}") }
  end
end
