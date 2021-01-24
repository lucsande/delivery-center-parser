class CreateJoinTablePaymentsOrders < ActiveRecord::Migration[5.2]
  def change
    create_join_table :payments, :orders do |t|
      t.index [:payment_id, :order_id]
      t.index [:order_id, :payment_id]
    end
  end
end
