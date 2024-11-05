require 'rails_helper'

RSpec.describe ChatRoomMembership, type: :model do
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room) }

  describe 'associations' do
    it 'belongs to a chat room' do
      membership = ChatRoomMembership.new(user: user, chat_room: chat_room)
      expect(membership.chat_room).to eq(chat_room)
    end

    it 'belongs to a user' do
      membership = ChatRoomMembership.new(user: user, chat_room: chat_room)
      expect(membership.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      membership = ChatRoomMembership.new(user: user, chat_room: chat_room)
      expect(membership).to be_valid
    end

    it 'is invalid without a user' do
      membership = ChatRoomMembership.new(chat_room: chat_room)
      expect(membership).not_to be_valid
    end

    it 'is invalid without a chat room' do
      membership = ChatRoomMembership.new(user: user)
      expect(membership).not_to be_valid
    end
  end

  describe 'database persistence' do
    it 'successfully saves a valid membership' do
      membership = ChatRoomMembership.new(user: user, chat_room: chat_room)
      expect { membership.save }.to change(ChatRoomMembership, :count).by(1)
    end

    it 'does not save an invalid membership' do
      membership = ChatRoomMembership.new
      expect { membership.save }.not_to change(ChatRoomMembership, :count)
    end
  end
end
