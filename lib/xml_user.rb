# frozen_string_literal: true

require 'config'
require 'date'
require 'json'
require 'nokogiri'

require_relative 'modules/xml_user_helpers'
require_relative 'modules/patron_groups'

Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

# Class to convert registry xml to a json object
class XmlUser
  include XmlUserHelpers

  attr_accessor :current_affiliation, :non_affiliated_users

  def initialize
    @hash = {
      users: [],
      'deactivateMissingUsers' => false,
      'updateOnlyPresentFields' => true
    }
    @non_affiliated_users = 0
  end

  def init_arrays
    @effective_dates = []
    @expiration_dates = []
    @group_array = []
    @priv_groups = []
  end

  def process_xml_lines(xml)
    File.readlines(xml).each do |xmlline|
      init_arrays

      affiliation_nodes = Nokogiri::XML(xmlline).xpath('//Person/affiliation')
      affiliation_nodes.empty? && @non_affiliated_users += 1
      affiliation_nodes.empty? && next

      person(Nokogiri::XML(xmlline).xpath('//Person'))
      next if @person_hash['username'].nil? || @person_hash['externalSystemId'].nil?

      privgroups(Nokogiri::XML(xmlline).xpath('//Person/privgroup'))
      name(Nokogiri::XML(xmlline).xpath('//Person/name[@type="display"]'))
      email(Nokogiri::XML(xmlline).xpath('//Person/email'))
      mobile_phone(Nokogiri::XML(xmlline).xpath('//Person/telephone[@type="mobile"]'))
      home_phone(Nokogiri::XML(xmlline).xpath('//Person/telephone[@type="permanent"]'))
      address(Nokogiri::XML(xmlline).xpath('//Person/place'))
      affiliation(affiliation_nodes)
      add_user_to_hash
    end
  end

  def privgroups(nodes)
    nodes.each do |priv|
      @priv_groups.push(priv.child.text)
    end
  end

  def person(nodes)
    @person_hash = {}

    nodes.each do |person|
      person = person.to_h
      @person_hash['username'] = person['sunetid']
      @person_hash['externalSystemId'] = person['univid']
      @person_hash['barcode'] = person['card'].to_s[5..-1]
      @person_hash['personal'] = {}
      @person_hash['personal']['addresses'] = []
      @person_hash['requestPreference'] = {}
      @person_hash['requestPreference']['holdShelf'] = true
      @person_hash['requestPreference']['delivery'] = false
      # Use to add 'workgroup' to this object if we use workgroup for permissions management.
      @person_hash['customFields'] = {}
    end
  end

  def name(nodes)
    nodes.each do |name|
      first_name(name)
      middle_name(name)
      last_name(name)
    end
  end

  def email(nodes)
    nodes.each do |email|
      @person_hash['personal']['email'] = Settings.user_email_override || email.content || ''
    end
    @person_hash['personal']['preferredContactTypeId'] = 'email'
  end

  def first_name(name)
    first = name.children.at_css('first')
    @person_hash['personal']['firstName'] = first.content if first
  end

  def last_name(name)
    last = name.children.at_css('last')
    @person_hash['personal']['lastName'] = last.content if last
  end

  def middle_name(name)
    middle = name.children.at_css('middle')
    @person_hash['personal']['middleName'] = middle.content if middle
  end

  def mobile_phone(nodes)
    nodes.each do |mobile|
      @person_hash['personal']['mobilePhone'] = mobile.children.first.content.strip
    end
  end

  def home_phone(nodes)
    nodes.each do |phone|
      @person_hash['personal']['phone'] = phone.children.first.content.strip
    end
  end

  def address(nodes)
    nodes.each do |address|
      @person_hash['personal']['addresses'] << local_address(address)
    end
  end

  def local_address(address)
    {
      'countryId' => check_if_nil(address.children.at_css('country'))['alpha2'],
      'addressLine1' => check_if_nil(address.children.at_css('line')).text,
      'city' => check_if_nil(address.children.at_css('city')).text,
      'region' => check_if_nil(address.children.at_css('state')).text,
      'postalCode' => check_if_nil(address.children.at_css('postalcode')).text,
      'addressTypeId' => address['type'].capitalize,
      'primaryAddress' => address['type'] == 'home'
    }
  end

  def add_user_to_hash
    # Remove previous user if it exists and insert the new user
    @hash[:users].delete_if { |user| user['username'] == @person_hash['username'] }
    @hash[:users] << @person_hash

    @hash[:totalRecords] = @hash[:users].size
  end
end
