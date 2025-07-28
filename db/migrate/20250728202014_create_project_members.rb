class CreateProjectMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :project_members do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: 'member', null: false

      t.index [:project_id, :user_id], unique: true


      t.timestamps
    end
  end
end
