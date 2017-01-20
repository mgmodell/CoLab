class AddReportDateToInstallment < ActiveRecord::Migration
  def change
    add_column :installments, :report_date, :datetime
  end
end
