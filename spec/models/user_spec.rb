require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'associations' do
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:chat_room_memberships).dependent(:destroy) }
    it { should have_many(:chat_rooms).through(:chat_room_memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:password_digest) }
    it { should have_secure_password }
  end

  describe 'password encryption' do
    it 'encrypts password' do
      user = User.create(email: 'test@example.com', full_name: 'Test User', password: 'password123')
      expect(user.password_digest).not_to eq('password123')
    end
  end

  describe 'email uniqueness' do
    it 'does not allow duplicate emails' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      expect(duplicate_user).not_to be_valid
    end

    it 'allows saving with different emails' do
      create(:user, email: 'test1@example.com')
      different_user = build(:user, email: 'test2@example.com')
      expect(different_user).to be_valid
    end
  end

  describe 'full name validation' do
    it 'is invalid without full name' do
      user = build(:user, full_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:full_name]).to include("can't be blank")
    end

    it 'is valid with full name' do
      user = build(:user, full_name: 'John Doe')
      expect(user).to be_valid
    end
  end
end
