class Card < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.text :title
      t.text :description
      t.integer :position
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
