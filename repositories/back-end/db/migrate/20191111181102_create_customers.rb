class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :status
      t.string :customer_id
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :birthdaydate
      t.string :email
      t.string :phone
      t.string :drivers_license
      t.string :notes

      t.timestamps
    end
  end
end
