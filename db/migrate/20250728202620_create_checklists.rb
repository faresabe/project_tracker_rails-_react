class CreateChecklists < ActiveRecord::Migration[8.0]
  def change
    create_table :checklists do |t|
      t.references :task, null: false, foreign_key: true
      t.string :item, null: false
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
