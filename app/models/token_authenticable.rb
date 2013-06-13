module TokenAuthenticable
  extend ActiveSupport::Concern

  included do
    attr_accessible       :authentication_token
    validates_presence_of :authentication_token

    before_validation     :ensure_authentication_token
  end

  module ClassMethods
    def friendly_token
      SecureRandom.base64(20).tr('+/=lIO0', 'pqrsxyz')
    end
  end

  def ensure_authentication_token
    self.authentication_token ||= self.class.friendly_token
  end
end
