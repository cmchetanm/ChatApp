require 'rails_helper'

RSpec.describe ChatRoomChannel, type: :channel do
  let(:chat_room) { create(:chat_room) }
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    it 'successfully subscribes to chat room stream' do
      subscribe room: chat_room.id
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("chat_room_#{chat_room.id}")
    end

    it 'raises error when chat room does not exist' do
      expect {
        subscribe room: -1
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'handles multiple subscriptions to same room' do
      subscribe room: chat_room.id
      expect(subscription).to be_confirmed
      
      another_subscription = subscribe room: chat_room.id
      expect(another_subscription).to be_confirmed
      expect(another_subscription).to have_stream_from("chat_room_#{chat_room.id}")
    end
  end
end
