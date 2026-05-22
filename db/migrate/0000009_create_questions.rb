class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.string :aid, null: false, limit: 14
      t.references :page, null: false, foreign_key: true
      t.references :account, null: true, foreign_key: true
      t.text :content, null: false, default: ""
      t.text :answer, null: false, default: ""
      t.boolean :read, null: false, default: false
      t.integer :visibility, null: false, limit: 1, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, null: false, limit: 1, default: 0

      t.timestamps
    end
    add_index :questions, :aid, unique: true
  end
end
