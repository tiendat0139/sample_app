class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_save{email.downcase!}
  before_create :create_activation_digest
  VALID_EMAIL_REGEX = Settings.regexes.email
  validates :name,  presence: true,
                    length: {maximum: Settings.digits.length_50}
  validates :email, presence: true,
                    length: {maximum: Settings.digits.length_255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  validates :password,  presence: true,
                        length: {minimum: Settings.digits.length_6},
                        allow_nil: true
  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
end
