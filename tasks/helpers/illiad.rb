# frozen_string_literal: true

require 'date'

# Module to encapsulate methods used by illiad tasks
module IlliadTaskHelpers
  include FolioRequestHelper

  def folio_json_users
    File.open('log/folio-user.log')
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
end
