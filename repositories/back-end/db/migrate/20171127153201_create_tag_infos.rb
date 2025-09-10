class CreateTagInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :tag_infos do |t|
      t.string :tag
      t.text :description

      t.timestamps
    end

    add_index :tag_infos, :tag, unique: :true
  end
end
