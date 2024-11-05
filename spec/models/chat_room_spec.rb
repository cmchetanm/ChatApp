require 'rails_helper'

RSpec.describe ChatRoom, type: :model do
  describe 'associations' do
    it 'has many messages' do
      should have_many(:messages).dependent(:destroy)
    end

    it 'has many chat_room_memberships' do
      should have_many(:chat_room_memberships).dependent(:destroy)
    end

    it 'has many users through chat_room_memberships' do
      should have_many(:users).through(:chat_room_memberships)
    end
  end

  describe 'validations' do
    it 'is valid with a name' do
      chat_room = ChatRoom.new(name: 'Test Room')
      expect(chat_room).to be_valid
    end

    it 'is invalid without a name' do
      chat_room = ChatRoom.new(name: nil)
      expect(chat_room).to_not be_valid
      expect(chat_room.errors[:name]).to include("can't be blank")
    end
  end

  describe 'database operations' do
    it 'can be created with valid attributes' do
      expect {
        ChatRoom.create!(name: 'Test Room')
      }.to change(ChatRoom, :count).by(1)
    end

    it 'deletes associated messages when destroyed' do
      chat_room = ChatRoom.create!(name: 'Test Room')
      message = chat_room.messages.create!(content: 'Test message', user: create(:user))
      
      expect {
        chat_room.destroy
      }.to change(Message, :count).by(-1)
    end

    it 'deletes associated memberships when destroyed' do
      chat_room = ChatRoom.create!(name: 'Test Room')
      membership = chat_room.chat_room_memberships.create!(user: create(:user))
      
      expect {
        chat_room.destroy
      }.to change(ChatRoomMembership, :count).by(-1)
    end
  end
end
