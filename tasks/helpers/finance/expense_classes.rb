# frozen_string_literal: true

require_relative '../folio_request'

# Module to encapsulate expense class methods used by finance_settings rake tasks
module ExpenseClassHelpers
  include FolioRequestHelper

  def expense_classes_csv
    CSV.parse(File.open("#{Settings.tsv}/acquisitions/expense-classes.tsv"), headers: true, col_sep: "\t").map(&:to_h)
  end

  def expense_class_id(code, expense_class_uuids)
    expense_class_uuids.fetch(code, nil)
  end

  def expense_class_id_list(codes, expense_class_uuids)
    list = []
    codes&.split(/,\s*/)&.each do |code|
      list << { 'expenseClassId' => expense_class_uuids.fetch(code, nil) }
    end
    # list = [{ 'expenseClassId' => 'abc-123' }, { 'expenseClassId' => 'xyz-456' }]
    list
  end

  def expense_class_delete(id)
    @@folio_request.delete("/finance/expense-classes/#{id}")
  end

  def expense_classes_post(obj)
    @@folio_request.post('/finance/expense-classes', obj.to_json)
  end

  def expense_class_put(id, obj)
    @@folio_request.put("/finance/expense-classes/#{id}", obj.to_json)
  end
end
