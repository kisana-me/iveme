class CreateBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :blocks do |t|
      t.string :aid, null: false, limit: 14
      t.references :page, null: false, foreign_key: true
      t.references :image, null: true, foreign_key: true
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.string :url, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.string :block_type, null: false, default: ""
      t.string :style, null: false, default: ""
      t.integer :visibility, null: false, limit: 1, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, null: false, limit: 1, default: 0

      t.timestamps
    end
    add_index :blocks, :aid, unique: true
  end
end
