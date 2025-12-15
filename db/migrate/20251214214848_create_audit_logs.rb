class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.text :comment, null: false, default: ''
      t.string :action, null: false
      t.references :user, null: false, foreign_key: true
      t.references :object, polymorphic: true

      t.timestamps
    end
  end
end
