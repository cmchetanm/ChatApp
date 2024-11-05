FactoryBot.define do
  factory :blacklisted_token do
    token { SecureRandom.uuid }
    exp { 1.day.from_now.to_i }
  end
end
