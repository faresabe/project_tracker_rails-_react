class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :status, default: "not_started", null: false
      t.string :priority, default: "low", null: false
      t.references :owner, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
