class BlacklistedToken < ApplicationRecord
  validates :token, presence: true
  validates :exp, presence: true
end