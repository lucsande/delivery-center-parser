
class CreateFailedOrderLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :failed_order_logs do |t|
      t.string :received_order_json
      t.string :error_message
      t.timestamps
    end
  end
end
