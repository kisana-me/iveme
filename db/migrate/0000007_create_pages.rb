class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :aid, null: false, limit: 14
      t.string :name_id, null: false
      t.references :account, null: false, foreign_key: true
      t.references :icon, null: true, foreign_key: { to_table: :images }
      t.references :background, null: true, foreign_key: { to_table: :images }
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.string :color, null: false, default: ""
      t.string :size, null: false, default: ""
      t.integer :visibility, null: false, limit: 1, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, null: false, limit: 1, default: 0

      t.timestamps
    end
    add_index :pages, :aid, unique: true
    add_index :pages, :name_id, unique: true
  end
end
