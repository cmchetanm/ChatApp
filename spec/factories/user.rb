FactoryBot.define do
	factory :user do
		email {Faker::Internet.email}
		full_name { Faker::Name.name }
		password { 'Test@123' }
	end
end
  
  