class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :contact
      t.string :marketplace_id

      t.timestamps
    end

    add_index :customers, :marketplace_id
  end
end
