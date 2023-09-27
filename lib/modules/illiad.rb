require 'config'
require 'active_model'
require 'tiny_tds'
require 'date'

Config.load_and_set_settings(Config.setting_files('config', ENV['STAGE'] || 'dev'))

class Illiad
  include ActiveModel::Model
  attr_accessor :folio_users

  def initialize(folio_users)
    @folio_users = folio_users
  end

  def stf_client
    TinyTds::Client.new username: 'STF', password: 'S!shrd*P455werd',
                        host: 'sul-illiad-prod.stanford.edu', port: '1433',
                        database: 'ILLData', login_timeout: 5
  end

  def get_stf_user
    resrault = stf_client.active? ? stf_client.execute(user(@username)).each : stf_client.close
    raise query_error("No results.") unless result.any?

    result
  end

  def load_illiad_users
    sql = []
    sql << begin_tran
    @folio_users[:users].each do |user|
      @user = user
      sql << insert_or_update_user
    end
    sql << commi_tran

    puts sql
    stf_client.active? ? stf_client.execute(sql).each : stf_client.close
  end

  def query_error(message)
    TinyTds::Error.new(message)
  end

  private


  def folio_user
    @user
  end

  def begin_tran
    "BEGIN TRAN " \
    "DECLARE @username VARCHAR(24) " \
  end

  def commi_tran
    "COMMIT TRAN;"
  end

  def insert_or_update_user
    "SET @username = '#{@user['username']}' " \
    "IF EXISTS (select * from ILLData.dbo.UsersALL WHERE UserName = @username) " \
    "  BEGIN " \
    "    UPDATE ILLData.dbo.UsersALL " \
    "    SET  " \
    "     #{key_value_pairs.map { |kvs| kvs.join(' = ')}.join(', ')}"\
    "    WHERE UserName = @username " \
    "  END " \
    "ELSE " \
    "  BEGIN " \
    "    INSERT INTO ILLData.dbo.UsersALL (#{illiad_keys.join(',')}) " \
    "    VALUES ( #{key_value_pairs.values.join(',')}) " \
    "  END " \
  end

  def key_value_pairs
    hash = {}
    folio_user.each do |key, value|
      if (key == 'personal')
        value.each do |k,v|
          hash[user_keys[k]] = sqlidify(v)
        end
      end
      hash[user_keys[key]] = sqlidify(value)
    end
    # hash['Status'] = sqlidify(patron_group)
    hash['NVTGC'] = sqlidify(nvtgc)
    hash['LastChangedDate'] = sqlidify(last_changed_date)
    hash['ExpirationDate'] = sqlidify(expiration_date)
    hash['NotificationMethod'] = sqlidify('Electronic')
    hash['DeliveryMethod'] = sqlidify('Hold for Pickup')
    hash['AuthorizedUsers'] = sqlidify('SUL')
    hash['Cleared'] = sqlidify('Yes')
    hash['Web'] = sqlidify('Yes')
    hash['AuthType'] = sqlidify('RemoteAuth')
    hash['Site'] = sqlidify('SUL')
    illiad_null_keys.each do |_key|
        hash[_key] = 'NULL'
    end

    ordered_hash(hash)
  end

  def ordered_hash(hash)
    ordered_hash = {}
    illiad_keys.each do |key|
      hash[key].nil? ? ordered_hash[key] = 'NULL' : ordered_hash[key] = hash[key]
    end

    ordered_hash
  end

  def user_keys
    {
      'username'=>'UserName',
      'lastName'=>'LastName',
      'firstName'=>'FirstName',
      'barcode'=>'SSN',
      'email'=>'EMailAddress',
      'phone'=>'Phone',
      'mobilePhone'=>'MobilePhone',
      'externalSystemId' => 'UserInfo1'
    }
  end

  def nvtgc
    departments = folio_user['departments']

    departments.each do |dept|
      return 'S7Z' if dept == 'Interlibrary Borrowing - GSB'
    end

    return 'STF'
  end

  def last_changed_date
    date = folio_user['updatedDate']
    begin
      Date.parse(date).strftime('%Y-%m-%d %H:%M:%S.%L')
    rescue TypeError => e
      ''
    end
  end

  def expiration_date
    begin
      date = folio_user['expirationDate']
      Date.parse(date).strftime('%Y-%m-%d %H:%M:%S.%L')
    rescue TypeError, Date::Error => e
      ''
    end
  end

  def illiad_null_keys
    %w[Department Password PasswordChangedDate LoanDeliveryMethod Address Address2 City State Zip
      Number UserRequestLimit Organization Fax ShippingAcctNo ArticleBillingCategory LoanBillingCategory
      Country SAddress SAddress2 SCity SState SZip PasswordHint SCountry RSSID UserInfo2 UserInfo3
      UserInfo4 UserInfo5]
  end

  def illiad_keys
    %w[UserName LastName FirstName SSN Status EMailAddress Phone MobilePhone Department
       NVTGC Password PasswordChangedDate NotificationMethod DeliveryMethod LoanDeliveryMethod
       LastChangedDate AuthorizedUsers Cleared Web Address Address2 City State Zip Site
       ExpirationDate Number UserRequestLimit Organization Fax ShippingAcctNo ArticleBillingCategory
       LoanBillingCategory Country SAddress SAddress2 SCity SState SZip PasswordHint SCountry RSSID
       AuthType UserInfo1 UserInfo2 UserInfo3 UserInfo4 UserInfo5]
  end

  def sqlidify(string)
    string.nil? ? 'NULL' : "'#{string}'"
  end
end