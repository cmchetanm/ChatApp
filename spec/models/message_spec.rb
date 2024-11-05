require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room) }
  let(:message) { build(:message, user: user, chat_room: chat_room, content: "Hello World") }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:chat_room) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe '#broadcast_message' do
    it 'broadcasts message after creation' do
      expect(ActionCable.server).to receive(:broadcast).once
      message.save
    end

    it 'does not broadcast if message is invalid' do
      invalid_message = build(:message, content: nil, user: user, chat_room: chat_room)
      expect(ActionCable.server).not_to receive(:broadcast)
      invalid_message.save
    end

    it 'formats created_at time correctly' do
      allow(ActionCable.server).to receive(:broadcast)
      message.save
      expect(ActionCable.server).to have_received(:broadcast).with(
        anything,
        hash_including(created_at: message.created_at.strftime('%H:%M:%S'))
      )
    end
  end
end
