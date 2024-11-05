require 'rails_helper'

RSpec.describe MessageSerializer do
  let(:user) { create(:user, full_name: 'John Doe', status: 'online') }
  let(:chat_room) { create(:chat_room, name: 'Test Room') }
  let(:message) { create(:message, user: user, chat_room: chat_room, content: 'Hello World') }
  let(:serializer) { described_class.new(message) }
  let(:serialization) { JSON.parse(serializer.to_json) }

  describe '#attributes' do
    it 'includes id and content' do
      expect(serialization).to include(
        'id' => message.id,
        'content' => 'Hello World'
      )
    end
  end

  describe '#user' do
    it 'includes the associated user' do
      expect(serialization).to include('user')
      expect(serialization['user']).to include('id' => user.id)
    end
  end

  describe '#chat_room' do
    it 'includes the associated chat room' do
      expect(serialization).to include('chat_room')
      expect(serialization['chat_room']).to include('id' => chat_room.id)
    end
  end

  describe '#channel_members' do
    let(:another_user) { create(:user, full_name: 'Jane Doe', status: 'offline') }
    
    before do
      chat_room.users << [user, another_user]
    end

    it 'includes all channel members with their details' do
      members = serialization['channel_members']
      expect(members).to be_an(Array)
      expect(members.length).to eq(2)
      
      expect(members).to include(
        {
          'id' => user.id,
          'full_name' => 'John Doe',
          'status' => 'online'
        },
        {
          'id' => another_user.id,
          'full_name' => 'Jane Doe',
          'status' => 'offline'
        }
      )
    end

    it 'returns empty array when chat room has no members' do
      chat_room.users.clear
      expect(serialization['channel_members']).to eq([])
    end
  end
end
