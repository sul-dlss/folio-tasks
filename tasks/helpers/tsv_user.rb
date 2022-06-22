# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by user_settings rake tasks
module TsvUserTaskHelpers
  include FolioRequestHelper

  def user_acq_units_and_permission_sets_tsv
    CSV.parse(File.open("#{Settings.tsv}/users/user-acq-units-and-permission-sets.tsv"),
              headers: true, col_sep: "\t").map(&:to_h)
  end

  def users_tsv
    CSV.parse(File.open("#{Settings.tsv}/users/tsv_users.tsv"), liberal_parsing: true, headers: true, col_sep: "\t")
       .map(&:to_h)
  end

  def user_notes(note_type)
    CSV.parse(File.open("#{Settings.tsv}/users/#{note_type}.tsv"), liberal_parsing: true, headers: true, col_sep: "\t")
       .map(&:to_h)
  end

  def user_note_types
    CSV.parse(File.open("#{Settings.tsv}/users/note_types.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def note_types_post(obj)
    @@folio_request.post('/note-types', obj)
  end

  def user_id(barcode)
    @@folio_request.get_cql('/users', "barcode=#{barcode}")['users'][0]&.dig('id')
  end

  def note_json(type, note, user)
    {
      typeId: type[1],
      type: type[0],
      title: "#{type[0]} note".upcase,
      domain: 'users',
      content: note.transform_keys(&:downcase)[type[0]],
      popUpOnCheckOut: false,
      popUpOnUser: false,
      links: [{
        id: user,
        type: 'user'
      }]
    }.to_json
  end

  def user_notes_post(json)
    @@folio_request.post('/notes', json)
  end

  def tsv_user
    size = 0
    user_hash = { 'users' => [], 'deactivateMissingUsers' => false, 'updateOnlyPresentFields' => true }
    users_tsv.each do |user|
      size += 1
      transform_user(user)
      user_hash['users'] << user
    end
    user_hash['totalRecords'] = size
    user_hash
  end

  def transform_user(user)
    user['username'] = user.values[0]
    user['barcode'] = user.values[0]
    user['externalSystemId'] = user.values[1]
    user['patronGroup'] = 'courtesy'
    user['personal'] = user_personal(user)
    user['enrollmentDate'] = enrollment(user['PRIV_GRANTED'])
    user['expirationDate'] = expiration(user['PRIV_EXPIRED'])
    user_group = Settings.usergroups.to_h[user['PATRON_CODE'].to_sym].to_s
    user['customFields'] = { 'usergroup' => user_group } unless user_group.size.zero?
    remove_temp_keys(user)
    user
  end

  def user_personal(user)
    {
      'lastName' => last_name(user['NAME']),
      'firstName' => first_name(user['NAME']),
      'middleName' => middle_name(user['NAME']),
      'email' => user['EMAIL'],
      'addresses' => [address(user)]
    }
  end

  def remove_temp_keys(user)
    user.shift # remove first element BARCODE
    user.delete('UNIV_ID')
    user.delete('NAME')
    user.delete('EMAIL')
    user.delete('ADDR_LINE1')
    user.delete('ADDR_LINE2')
    user.delete('CITY')
    user.delete('STATE')
    user.delete('ZIP')
    user.delete('PRIV_GRANTED')
    user.delete('PRIV_EXPIRED')
    user.delete('PATRON_CODE')
    user
  end

  def middle_name(name)
    middle = name.split(',')[1] unless name.nil?
    middle.split[1] unless middle.nil?
  end

  def last_name(name)
    name.split(',')[0] unless name.nil?
  end

  def first_name(name)
    first = name.split(',')[1] unless name.nil?
    first.split[0] unless first.nil?
  end

  def expiration(str)
    str.match?(/\d{8}/) ? Date.parse(str, '%Y%m%d').strftime('%Y-%m-%d') : ''
  end

  def enrollment(str)
    str.match?(/\d{8}/) ? Date.parse(str, '%Y%m%d').strftime('%Y-%m-%d') : ''
  end

  def address(user)
    {
      'addressLine1' => user['ADDR_LINE1'],
      'addressLine2' => user['ADDR_LINE2'],
      'city' => user['CITY'],
      'region' => user['STATE'],
      'postalCode' => user['ZIP']
    }
  end
end
