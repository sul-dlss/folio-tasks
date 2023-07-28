# frozen_string_literal:true

require_relative 'xml_user_helpers'

# Defines conditions for each patron group that is created
class PatronGroups
  include XmlUserHelpers

  def initialize(aff, privgroups)
    @aff = aff
    @priv_groups = privgroups
  end

  def faculty
    Settings.faculty.map { |f| @aff['type'].start_with?(f) }.first
  end

  def postdoctoral
    @aff['type'].start_with?('student') && ((%w[student:phd student:postdoc student:doctoral] & @priv_groups).any? ||
      affiliation_affdata.include?('law jsd'))
  end

  def graduate
    @aff['type'] == 'student:mla' ||
      (
        Settings.student.include?(@aff['type']) &&
          (
            affiliation_description.any? do |a|
              a.start_with?('graduate')
            end || (%w[student:coterminal] & @priv_groups).any?
          )
      )
  end

  def undergrad
    @aff['type'].start_with?('student') && affiliation_description.include?('undergraduate')
  end

  def affiliation_affdata
    data = []
    @aff.children.each do |child|
      data.push child.text.downcase if child.name == 'affdata'
    end

    data
  end

  def affiliation_description
    data = []
    @aff.children.each do |child|
      data.push child.text.downcase if child.name == 'description'
    end

    data
  end
end
