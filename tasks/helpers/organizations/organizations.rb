# frozen_string_literal: true

# Module to encapsulate methods used by organizations rake tasks
module OrganizationsTaskHelpers
  def organizations_delete(id)
    FolioRequest.new.delete("/organizations/organizations/#{id}")
  end

  def organizations_post(obj)
    FolioRequest.new.post('/organizations/organizations', obj)
  end

  def organizations_put(id, obj)
    FolioRequest.new.put("/organizations/organizations/#{id}", obj)
  end
end
