module Sanitizable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :stripable_fields
    attr_reader :upcaseable_fields

    private

    def stripable(fields = [])
      fields = [fields] unless fields.class == Array
      @stripable_fields = fields
    end

    def upcaseable(fields = [])
      fields = [fields] unless fields.class == Array
      @upcaseable_fields = fields
    end
  end

  included do
    before_validation :sanitize_fields
  end

  def sanitize_fields
    self.class.stripable_fields.each do |field|
      self[field].strip! if self[field].present?
    end if self.class.stripable_fields.present?
    self.class.upcaseable_fields.each do |field|
      self[field].upcase! if self[field].present?
    end if self.class.upcaseable_fields.present?
  end
end
