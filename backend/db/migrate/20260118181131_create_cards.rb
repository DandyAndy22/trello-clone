class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.text :title
      t.text :description
      t.integer :position
      t.references :lists, null: false, foreign_key: true

      t.timestamps
    end
  end
end
