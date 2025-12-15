module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable

    after_save :audit_save
    before_destroy :audit_destroy
  end

  def audit_save
    action = self.id_before_last_save.nil? ? 'create' : 'update'
    AuditLog.create(object: self, action: action, user: Current.user, comment: 'Update' + ' ' + self.saved_changes.keys.join(', '))
  end

  def audit_destroy
    AuditLog.create(object: self, action: 'destroy', user: Current.user, comment: 'Destroy')
  end
end