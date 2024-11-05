require 'rails_helper'

RSpec.describe ChatRoomSerializer do
  let(:user) { create(:user, email: 'test@example.com', full_name: 'Test User') }
  let(:chat_room) { create(:chat_room, name: 'Test Room', private: false) }
  let(:serializer) { described_class.new(chat_room) }

  before do
    chat_room.users << user
  end

  describe '#serialized_json' do
    let(:serialized_chat_room) { JSON.parse(serializer.to_json) }

    it 'includes the correct attributes' do
      expect(serialized_chat_room.keys).to match_array(['id', 'name', 'private', 'users'])
    end

    it 'has the correct values for basic attributes' do
      expect(serialized_chat_room['id']).to eq(chat_room.id)
      expect(serialized_chat_room['name']).to eq('Test Room')
      expect(serialized_chat_room['private']).to eq(false)
    end

    it 'serializes users with correct attributes' do
      serialized_user = serialized_chat_room['users'].first
      expect(serialized_user['id']).to eq(user.id)
      expect(serialized_user['email']).to eq('test@example.com')
      expect(serialized_user['full_name']).to eq('Test User')
    end

    it 'handles multiple users correctly' do
      another_user = create(:user, email: 'another@example.com', full_name: 'Another User')
      chat_room.users << another_user

      expect(serialized_chat_room['users'].length).to eq(2)
      expect(serialized_chat_room['users'].map { |u| u['id'] }).to contain_exactly(user.id, another_user.id)
    end

    it 'handles chat room with no users' do
      empty_chat_room = create(:chat_room)
      empty_serializer = described_class.new(empty_chat_room)
      
      expect(JSON.parse(empty_serializer.to_json)['users']).to eq([])
    end
  end
end
