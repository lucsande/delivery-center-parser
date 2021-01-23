class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :marketplace_id
      t.references :store, foreign_key: true
      t.float :subtotal
      t.float :deivery_fee
      t.float :tota_shipping
      t.float :total
      t.string :country
      t.string :state
      t.string :city
      t.string :district
      t.string :street
      t.string :complement
      t.float :latitude
      t.float :longitude
      t.string :marketplace_creation_date
      t.string :postal_code
      t.integer :address_number
      t.references :customer, foreign_key: true
      t.references :product, foreign_key: true
      t.string :product_quantity
      t.string :payment_type

      t.timestamps
    end
  end
end
