class User < ApplicationRecord
  has_secure_password
  has_many :boards, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: :password_required?

  private

  def password_required?
    password_digest.nil? || password.present?
  end
end
