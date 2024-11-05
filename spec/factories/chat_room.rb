FactoryBot.define do
    factory :chat_room do
      name { Faker::Name.name }
    end
  end
  
  