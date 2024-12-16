# frozen_string_literal: true

require 'rake'
require 'spec_helper'

describe 'fix orders' do
  let(:restore_po_line_task) { Rake.application.invoke_task('orders:restore_po_line[po_line_ids.txt]') }

  before do
    stub_request(:post, 'http://example.com/authn/login')
      .with(body: Settings.okapi.login_params.to_h)

    stub_request(:get, %r{.*audit-data/acquisition/order-line/28801a5f-396c-48c1-8f6b-cb92f5d428d1.*})
      .to_return(body: '{ "orderLineAuditEvents": [
                          {
                            "id": "9b1f4003-a0cb-490b-a1e8-bf0d8a55431d",
                            "action": "Edit",
                            "orderId": "357fc527-57d7-4bb3-9215-c2e7c418c789",
                            "orderLineId": "28801a5f-396c-48c1-8f6b-cb92f5d428d1",
                            "userId": "1da4a196-c7a6-4a6b-8099-6cb51a97b1ed",
                            "eventDate": "2024-11-28T01:29:53.389+00:00",
                            "actionDate": "2024-11-28T01:29:53.373+00:00",
                            "orderLineSnapshot": {
                                "map": {
                                    "id": "28801a5f-396c-48c1-8f6b-cb92f5d428d1",
                                    "instanceId": "a83f714d-efa3-4747-8aba-4c56d9fac8a1",
                                    "orderFormat": "Physical Resource",
                                    "checkinItems": false,
                                    "poLineNumber": "145479-1",
                                    "paymentStatus": "Pending",
                                    "receiptStatus": "Pending",
                                    "purchaseOrderId": "357fc527-57d7-4bb3-9215-c2e7c418c789"
                                },
                                "empty": false
                            }
                          },
                          {
                            "id": "a71afe2c-2da2-4a69-aefe-b46ff7913521",
                            "action": "Edit",
                            "orderId": "357fc527-57d7-4bb3-9215-c2e7c418c789",
                            "orderLineId": "28801a5f-396c-48c1-8f6b-cb92f5d428d1",
                            "userId": "1da4a196-c7a6-4a6b-8099-6cb51a97b1ed",
                            "eventDate": "2024-11-25T22:23:18.671+00:00",
                            "actionDate": "2024-11-25T22:23:18.652+00:00",
                            "orderLineSnapshot": {
                                "map": {
                                    "id": "28801a5f-396c-48c1-8f6b-cb92f5d428d1",
                                    "instanceId": "a83f714d-efa3-4747-8aba-4c56d9fac8a1",
                                    "orderFormat": "Physical Resource",
                                    "checkinItems": false,
                                    "poLineNumber": "145479-1",
                                    "paymentStatus": "Awaiting Payment",
                                    "receiptStatus": "Awaiting Receipt",
                                    "purchaseOrderId": "357fc527-57d7-4bb3-9215-c2e7c418c789"
                                },
                                "empty": false
                            }
                          }],
                          "totalItems": 5 }')

    stub_request(:get, %r{.*audit-data/acquisition/order-line/70508494-a82c-4d72-b960-42d516f23a5f.*})
      .to_return(body: '{ "orderLineAuditEvents": [{
                            "id": "b743436b-8687-4fee-b4dd-b7eb3e65864c",
                            "action": "Edit",
                            "orderId": "a8f17930-a9cf-4415-b4a1-5cb4e3ed5d68",
                            "orderLineId": "70508494-a82c-4d72-b960-42d516f23a5f",
                            "userId": "53259d2f-c95b-4ba1-99b6-46181adb2822",
                            "eventDate": "2024-11-28T00:35:53.127+00:00",
                            "actionDate": "2024-11-28T00:35:53.112+00:00",
                            "orderLineSnapshot": {
                                "map": {
                                    "id": "70508494-a82c-4d72-b960-42d516f23a5f",
                                    "instanceId": "14588071-f665-4c69-8022-cdefea498ccb",
                                    "orderFormat": "Physical Resource",
                                    "receiptDate": "2024-11-28T00:35:53.104+00:00",
                                    "checkinItems": false,
                                    "poLineNumber": "145466-1",
                                    "paymentStatus": "Awaiting Payment",
                                    "receiptStatus": "Fully Received",
                                    "purchaseOrderId": "a8f17930-a9cf-4415-b4a1-5cb4e3ed5d68"
                                  },
                                "empty": false
                            }
                        }],
                    "totalItems": 8 }')

    stub_request(:get, %r{.*audit-data/acquisition/order-line/278d3cf3-e170-4316-a1cd-37e0d70a5044.*})
      .to_return(status: 500, # when there are no audit events for a given po line UUID okapi returns 500
                 body: '{ "errors": [
                              {
                                  "message": "Error at index 11 in: \"42d516f23a5j\"",
                                  "code": "genericError",
                                  "parameters": [
                                  ]
                              }
                          ],
                          "total_records": 1
                      }')

    stub_request(:put, %r{.*orders-storage/po-lines/.*})
      .to_return(status: 204)
  end

  context 'when querying for po line audit events' do
    it 'reads the po line ids file into an array' do
      po_line_ids = restore_po_line_task.send(:po_line_ids_file, 'po_line_ids.txt')
      expect(po_line_ids).to be_an_instance_of(Array)
    end

    it 'send the po line id in the query' do
      audit_events = restore_po_line_task.send(:audit_acq_order_lines, '28801a5f-396c-48c1-8f6b-cb92f5d428d1', limit: 2, offset: 0)
      expect(audit_events).to have_requested(:get, 'http://example.com/audit-data/acquisition/order-line/28801a5f-396c-48c1-8f6b-cb92f5d428d1?sortBy=action_date&sortOrder=desc&limit=2&offset=0').at_least_once
    end
  end

  context 'when processing audit events data' do
    let(:audit_events) { restore_po_line_task.send(:audit_acq_order_lines, '28801a5f-396c-48c1-8f6b-cb92f5d428d1', limit: 2, offset: 0) }
    let(:po_line_audit_events) { audit_events.fetch('orderLineAuditEvents', []) }

    it 'passes an array of po line audit events to get previous version' do
      expect(po_line_audit_events).to be_an_instance_of(Array)
    end

    it 'selects the previous version audit event' do
      previous_version = previous_version_audit_event(po_line_audit_events)
      expect(previous_version['paymentStatus']).to eq 'Awaiting Payment'
    end
  end

  context 'when po line has only one event from audit data' do
    let(:audit_events) { restore_po_line_task.send(:audit_acq_order_lines, '70508494-a82c-4d72-b960-42d516f23a5f', limit: 2, offset: 0) }
    let(:po_line_audit_events) { audit_events.fetch('orderLineAuditEvents', []) }
    let(:previous_version) { previous_version_audit_event(po_line_audit_events) }

    it 'previous_version_audit_event returns an empty array' do
      expect(previous_version.length).to eq 0
    end
  end

  context 'when po line does not have any audit data' do
    let(:audit_events) { restore_po_line_task.send(:audit_acq_order_lines, '278d3cf3-e170-4316-a1cd-37e0d70a5044', limit: 2, offset: 0) }
    let(:po_line_audit_events) { audit_events.fetch('orderLineAuditEvents', []) }
    let(:previous_version) { previous_version_audit_event(po_line_audit_events) }

    it 'previous_version_audit_event returns an empty array' do
      expect(previous_version.length).to eq 0
    end
  end
end
