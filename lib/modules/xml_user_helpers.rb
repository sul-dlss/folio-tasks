# frozen_string_literal: true

# Non-XML-parsing Helper functions
module XmlUserHelpers
  # TODO: check whether expiration date for old affiliations will cause a problem
  def active?
    return false if Settings.nonactive_types.include?(current_affiliation['type']) && @group_array.empty?

    not_expired?(current_affiliation['type']) && effective?
  end

  def add_aff_data_to_group_array
    special_patron_group = PatronGroups.new(current_affiliation, @priv_groups)
    groups_ranked.each do |group|
      if belongs_to_patron_group(group, special_patron_group)
        @group_array.push([group, effective_date, until_date.nil? ? '' : until_date])
      end
    end
  end

  def affiliation(nodes)
    nodes.each_with_index do |aff, index|
      @current_affiliation = aff

      # If expired or not enrolled or no valid patron group, set "active" to false.
      if active?
        add_aff_data_to_group_array
        apply_patron_group
        other_affiliation(aff, index)
        # Use 'permissions' method to for workgroups or remove this method call if we end up not needing this.
        # permissions
      elsif @group_array.empty?
        apply_nonactive
        index.zero? && warn("#{@person_hash['username']} #{aff['type']}")
      end
      @person_hash['customFields']['affiliation'] = aff['type'] if index.zero?
    end
  end

  def apply_active
    @person_hash['active'] = true if @person_hash['patronGroup']
  end

  def apply_enrollment
    return if patron_group_enrollment_date == '1000-01-01'

    @person_hash['enrollmentDate'] = patron_group_enrollment_date
  end

  def apply_expiration
    return unless patron_group_expiration_date

    @person_hash['expirationDate'] = patron_group_expiration_date
  end

  def apply_nonactive
    @person_hash['active'] = false
  end

  def apply_patron_group
    if @group_array.empty?
      apply_nonactive
      return
    end

    @group_array.sort_by! { |aff, _effective, _until| groups_ranked.index(aff) }

    @person_hash['patronGroup'] = patron_group
    apply_enrollment
    apply_expiration
    apply_active
  end

  def belongs_to_patron_group(group, patron_group)
    method = group.downcase.gsub(/\W+/, '_')
    return true if (patron_group.respond_to?(method) && patron_group.send(method)) ||
                   Settings.send(method)&.include?(current_affiliation['type'])
  end

  def check_if_nil(element)
    return Nokogiri::XML('</>') if element.nil?

    element
  end

  def effective?
    # new staff will have effective_date = tomorrow
    (effective_date.nil? || effective_date <= Date.today || effective_date == Date.today + 1)
  end

  def effective_date
    return Date.strptime('1000-01-01', '%Y-%m-%d') unless current_affiliation['effective']

    Date.strptime(current_affiliation['effective'], '%Y-%m-%d')
  end

  def faculty_or_staff?(aff)
    aff.match?(/faculty|staff/)
  end

  def groups_ranked
    Settings.groups_ranked
  end

  def not_expired?(aff)
    if until_date
      return true if until_date > Date.today
    elsif faculty_or_staff?(aff)
      return true
    end
    false
  end

  def other_affiliation(aff, index)
    return if @person_hash['customFields']['secondaffiliation']

    @person_hash['customFields']['secondaffiliation'] = aff['type'] if index.positive?
  end

  def patron_group
    @group_array[0][0] || ''
  end

  def patron_group_enrollment_date
    @group_array[0][1] || ''
  end

  def patron_group_expiration_date
    @group_array[0][2] || ''
  end

  # Use to add workgroup permissions or remove this method if we end up not needing this.
  # def permissions
  #   @priv_groups.select { |p| p.include?('folio:') && @person_hash['customFields']['workgroup'] = p }
  # end

  def add_departments
    @person_hash['departments'] = []
    # Add the default SUL department
    @priv_groups.select do |p|
      p.include?('organization:gsb') && @person_hash['departments'] << 'Interlibrary Borrowing - GSB'
      p.include?('organization:law') && @person_hash['departments'] << 'Interlibrary Borrowing - LAW'
      p.include?('organization:medicine') && @person_hash['departments'] << 'Interlibrary Borrowing - LANE'
    end
    @person_hash['departments'].length.zero? && @person_hash['departments'] << 'Interlibrary Borrowing - SUL'
  end

  def to_json(*)
    @hash.to_json
  end

  def until_date
    return unless current_affiliation['until']

    Date.strptime(current_affiliation['until'], '%Y-%m-%d')
  end
end
