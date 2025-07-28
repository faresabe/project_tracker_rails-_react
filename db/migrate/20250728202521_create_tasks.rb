class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :due_date
      t.references :assignee, null: false, foreign_key: true
      t.string :status
      t.string :priority
      t.integer :parent_task_id

      t.timestamps
    end
  end
end
