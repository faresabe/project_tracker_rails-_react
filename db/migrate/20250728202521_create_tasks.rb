class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :due_date
      t.references :assignee, foreign_key: {to_table: :users}
      t.string :status, default: "not_started", null: false
      t.string :priority, default: "low", null: false   
      t.references :parent_task, foreign_key: { to_table: :tasks }
      t.timestamps
    end 
  end
end
