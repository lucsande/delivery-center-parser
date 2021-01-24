class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :type
      t.float :value

      t.timestamps
    end

    add_index :payments, :type
  end
end
