# frozen_string_literal: true

require_relative '../helpers/folio_request'

# Module to encapsulate methods used by user_settings rake tasks
module TsvUserTaskHelpers
  include FolioRequestHelper

  def user_acq_units_and_permission_sets_tsv
    CSV.parse(File.open("#{Settings.tsv}/users/user-acq-units-and-permission-sets.tsv"),
              headers: true, col_sep: "\t").map(&:to_h)
  end

  def app_users_permission_sets_tsv
    CSV.parse(File.open("#{Settings.tsv}/users/app_users_psets.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def users_tsv(file)
    CSV.parse(File.open("#{Settings.tsv}/users/#{file}"), liberal_parsing: true, headers: true, col_sep: "\t")
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

  def tsv_user(group)
    size = 0
    user_hash = { 'users' => [], 'deactivateMissingUsers' => false, 'updateOnlyPresentFields' => true }
    group.each do |user|
      size += 1
      transform_user(user)
      user_hash['users'] << user
    end
    user_hash['totalRecords'] = size
    user_hash
  end

  def app_user(user)
    group_id = patron_group_id(user['PATRON_GROUP'])
    user['id'] = deterministic_user_id(user['username'])
    user['personal'] = user_personal(user)
    user['patronGroup'] = group_id unless group_id.nil?
    user.delete('password')
    user.delete('EMAIL')
    user.delete('NAME')
    user.delete('PATRON_GROUP')
    user
  end

  def app_user_credentials(user)
    {
      'userId' => deterministic_user_id(user['username']),
      'password' => user['password']
    }
  end

  def app_user_id_hash(user)
    { 'userId' => deterministic_user_id(user['username']) }
  end

  def patron_group_id(group)
    user_group = @@folio_request.get_cql('/groups', "group==#{group}")
    return if user_group.nil?

    user_group['usergroups'][0]['id']
  end

  def tsv_patron_group(user)
    return Settings.defaultgroup.to_s unless user['PATRON_CODE']

    policygroup = Settings.policygroups.to_h[user['PATRON_CODE'].to_sym].to_s
    courtesygroup = Settings.courtesygroups.to_h[user['PATRON_CODE'].to_sym].to_s

    return Settings.defaultgroup.to_s unless [policygroup, courtesygroup].any?

    if !policygroup.empty?
      policygroup
    elsif !courtesygroup.empty?
      courtesygroup
    end
  end

  def user_group(user)
    return {} unless user['PATRON_CODE']

    user_group = Settings.usergroups.to_h[user['PATRON_CODE'].to_sym].to_s
    { 'usergroup' => user_group } unless user_group.empty?
  end

  def transform_user(user)
    user['username'] = user_name(user)
    user['barcode'] = user.values[0]
    user['externalSystemId'] = user.values[1]
    user['patronGroup'] = tsv_patron_group(user)
    user['personal'] = user_personal(user)
    user['enrollmentDate'] = enrollment(user['PRIV_GRANTED'])&.strftime('%Y-%m-%d')
    user['expirationDate'] = expiration(user['PRIV_EXPIRED'])&.strftime('%Y-%m-%d')
    user['customFields'] = user_group(user)
    user['active'] = active(user)
    remove_temp_keys(user)
    user
  end

  def user_name(user)
    return user.values[0] unless user['SUNET']

    user['SUNET']
  end

  def user_personal(user)
    personal = {}
    last = last_name(user['NAME'])
    first = first_name(user['NAME'])
    middle = middle_name(user['NAME'])

    personal['lastName'] = last unless last.nil?
    personal['firstName'] = first unless first.nil?
    personal['middleName'] = middle unless middle.nil?
    personal['email'] = email_address(user)
    personal['addresses'] = [address(user)] unless check_address(user)
    personal
  end

  def email_address(user)
    Settings.user_email_override || user['EMAIL'] || ''
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
    user.delete('SUNET')
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

  def active(user)
    expiry = expiration(user['PRIV_EXPIRED'])
    return false if expiry.nil?

    expiry > Date.today || false
  end

  def expiration(str)
    str.match?(/\d{8}/) ? Date.parse(str, '%Y%m%d') : nil
  end

  def enrollment(str)
    str.match?(/\d{8}/) ? Date.parse(str, '%Y%m%d') : nil
  end

  def check_address(user)
    failed = false
    vals = %w[ADDR_LINE1 ADDR_LINE2 CITY STATE ZIP]
    vals.each { |v| failed = true if user[v].nil? }
    failed
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

  def psets_from_cols(psets_tsv)
    psets = psets_tsv[0].keys
    psets.delete('SUNetID')
    psets.delete('Acq Unit')
    psets.delete('Service Point')
    psets.delete('Notes')
    psets
  end

  def perms_assign(psets_tsv)
    pset_hash = {}
    @@folio_request.get('/perms/permissions?length=10000&query=(mutable==true)')['permissions'].each do |permission|
      pset_hash[permission['displayName']] = permission['id']
    end
    reset_user_perms(pset_hash, psets_tsv)
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def reset_user_perms(pset_hash, psets_tsv)
    pset_names = psets_from_cols(psets_tsv)
    psets_tsv.each do |line|
      username = user_get(line['SUNetID'])
      username && username['users'].each do |user|
        user_permissions_get(user['id'])['permissionNames'].each do |permission|
          if permission['mutable'] && (pset_names.include? permission['displayName'])
            @@folio_request
              .delete("/perms/users/#{user['id']}/permissions/#{permission['permissionName']}?indexField=userId")
          end
        end
        pset_names.each do |pset|
          if line[pset] && pset_hash[pset]
            pset_obj = { 'permissionName' => pset_hash[pset] }
            @@folio_request.post("/perms/users/#{user['id']}/permissions?indexField=userId", pset_obj.to_json)
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def service_points_assign
    service_point_hash = Uuids.service_points
    user_acq_units_and_permission_sets_tsv.each do |obj|
      service_point = obj['Service Point']
      service_point_id = service_point_hash[service_point]
      users = user_get(obj['SUNetID'])
      service_point_id && users && users['users'].each do |user|
        user_service_point(user_service_point_hash(user['id'], service_point_id))
      end
    end
  end
end
