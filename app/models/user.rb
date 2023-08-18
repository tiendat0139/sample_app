class User < ApplicationRecord
  before_save{email.downcase!}
  VALID_EMAIL_REGEX = Settings.regexes.email
  validates :name,  presence: true,
                    length: {maximum: Settings.digits.length_50}
  validates :email, presence: true,
                    length: {maximum: Settings.digits.length_255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  validates :password,  presence: true,
                        length: {minimum: Settings.digits.length_6}
  has_secure_password
end
