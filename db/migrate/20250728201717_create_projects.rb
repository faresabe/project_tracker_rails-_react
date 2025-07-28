class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.integer :priority
      t.references :owner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
