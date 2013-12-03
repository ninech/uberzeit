module CustomerAssignable
  extend ActiveSupport::Concern

  included do
    attr_accessible :customer_number

    belongs_to :customer, with_deleted: true

    validate :customer_must_exist
    validates_presence_of :customer_id

    after_validation :copy_customer_number_errors_from_customer_id

    scope :by_customer, ->(customer) { where(customer_id: customer) }
  end

  def customer_number
    return @customer_number unless @customer_number.nil?
    return nil if customer.nil?
    customer.number
  end

  def customer_number=(customer_number)
    @customer_number = customer_number
    customer = Customer.where(number: customer_number).last
    self.customer_id = customer.id unless customer.nil?
  end

  private
  def customer_must_exist
    errors.add(:customer_id, :customer_does_not_exist) unless customer_id.blank? || Customer.exists?(customer_id)
  end

  def copy_customer_number_errors_from_customer_id
    errors.messages[:customer_number] = errors.messages[:customer_id] if errors.messages[:customer_id]
  end
end
