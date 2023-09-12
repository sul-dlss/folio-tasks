# frozen_string_literal: true

require 'date'

# Module to encapsulate methods used by illiad tasks
module IlliadTaskHelpers
  include FolioRequestHelper

  def folio_json_users(date=nil)
    filename = 'log/folio-user.log'
    date.nil? ? file = filename : file = "#{filename}.#{date}"
    File.open(file)
  end

  def illiad_user(folio_user)
    user = folio_user['users'][0]
    {
      Username: user['username'],
      LastName: user['personal']['lastName'],
      FirstName: user['personal']['firstName'],
      SSN: user['barcode'],
      Status: user['patronGroup'],
      EMailAddress: user['personal']['email'],
      Phone: user['personal']['phone'],
      ExpirationDate: user['expirationDate'],
      UserInfo1: user['externalSystemId'],
      NVTGC: 'ST2',
      NotificationMethod: 'Electronic',
      DeliveryMethod: 'Hold for Pickup',
      AuthorizedUsers: 'SUL',
      Cleared: 'Yes',
      Site: 'SUL',
      Organization: 'SUL',
      LastChangedDate: DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    }.to_json
  end

  def illiad_response(response, user)
    puts "Got response code #{response} for #{user}" unless response == 200
  end
end
