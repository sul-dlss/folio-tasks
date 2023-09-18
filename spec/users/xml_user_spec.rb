# frozen_string_literal: true

require 'rake'
require 'spec_helper'
require_relative '../../lib/xml_user'

RSpec.describe XmlUser do
  let(:result) { described_class.new }

  describe 'user records' do
    context 'when a peron has multiple active and inactive affiliations' do
      before do
        result.process_xml_lines('spec/fixtures/xml/users/registry_harvest.xml.txt')
      end

      it 'has users in an array' do
        users = JSON.parse(result.to_json)['users']
        expect(users).to be_a Array
      end

      it 'has one or more user records' do
        users = JSON.parse(result.to_json)['users']
        expect(users.length).to be > 0
      end

      it 'has addresses in an array' do
        addresses = JSON.parse(result.to_json)['users'][0]['personal']['addresses']
        expect(addresses).to be_a Array
      end

      it 'has one or more addresses' do
        addresses = JSON.parse(result.to_json)['users'][0]['personal']['addresses']
        expect(addresses.length).to be > 1
      end

      it 'has a fake email if configured' do
        email = JSON.parse(result.to_json)['users'][0]['personal']['email']
        expect(email).to eq 'foliotesting@lists.stanford.edu'
      end

      it 'gets enrollmentDate associated with ranked patron group' do
        date = JSON.parse(result.to_json)['users'][0]['enrollmentDate']
        expect(date).to eq '2020-09-01'
      end

      it 'gets expirationDate associated with ranked patron group' do
        date = JSON.parse(result.to_json)['users'][0]['expirationDate']
        expect(date).to eq '2030-09-01'
      end

      it 'has active as true' do
        expect(JSON.parse(result.to_json)['users'][0]['active']).to be_truthy
      end

      it 'sets the affiliation custom field to their best active affiliation' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']['affiliation']).to eq 'staff'
      end

      it 'sets the other_affiliation custom field to their next active affiliation if any' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']['secondaffiliation']).to eq 'staff:academic'
      end

      it 'sets the proximityChipId custom field' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']['proximitychipid']).to eq '0123456'
      end

      it 'sets the mobileId custom field' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']['mobileid']).to eq '0511111'
      end

      # Use to test workgroup permissions or remove this method if we end up not needing this.
      # it 'has custom workgroup field if there is a folio privgroup' do
      #   expect(JSON.parse(result.to_json)['users'][0]['customFields']['workgroup']).to eq 'folio:circ-staff'
      # end

      it 'has the department field with the default value' do
        expect(JSON.parse(result.to_json)['users'][0]['departments'].length).to be_positive
      end

      it 'has the correct patron group' do
        expect(JSON.parse(result.to_json)['users'][0]['patronGroup']).to eq 'staff'
      end
    end

    context 'when a person has no active affiliations' do
      before do
        result.process_xml_lines('spec/fixtures/xml/users/nonactive_staff.xml.txt')
      end

      it 'has active as false' do
        expect(JSON.parse(result.to_json)['users'][0]['active']).to be_falsy
      end

      it 'has custom affiliation field showing inactive affiliation type' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']['affiliation']).to eq 'staff:nonactive'
      end
    end

    context 'when a person is a doctoral student' do
      before do
        result.process_xml_lines('spec/fixtures/xml/users/doctoral_student.xml.txt')
      end

      it 'has the correct patron group' do
        expect(JSON.parse(result.to_json)['users'][0]['patronGroup']).to eq 'postdoctoral'
      end
    end

    context 'when a person is a coterminal student' do
      before do
        result.process_xml_lines('spec/fixtures/xml/users/coterminal_student.xml.txt')
      end

      it 'has the correct patron group' do
        expect(JSON.parse(result.to_json)['users'][0]['patronGroup']).to eq 'graduate'
      end
    end

    context 'when there is no custom field value' do
      before do
        result.process_xml_lines('spec/fixtures/xml/users/no_custom_fields.xml.txt')
      end

      it 'does not include proximitychipid in the custom fields' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']).not_to include('proximitychipid')
      end

      it 'does not include mobileid in the custom fields' do
        expect(JSON.parse(result.to_json)['users'][0]['customFields']).not_to include('mobileid')
      end
    end
  end
end
