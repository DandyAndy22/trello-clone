class AddDueDateToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :due_date, :date
  end
end
