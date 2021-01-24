class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.references :payment_type, foreign_key: true
      t.references :order, foreign_key: true
      t.float :value

      t.timestamps
    end
  end

  # add_index :payment_types, :name
end
