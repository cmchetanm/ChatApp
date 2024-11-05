require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  include JsonWebToken
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room) }
  let(:token) { jwt_encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST #create' do
    context 'when user is a member of the chat room' do
      before do
        chat_room.users << user
      end

      it 'creates a new message successfully' do
        post :create, params: { 
          chat_room_id: chat_room.id, 
          message: { content: 'Hello World' } 
        }
        expect(response).to have_http_status(:success)
        expect(chat_room.messages.last.content).to eq('Hello World')
      end

      it 'returns error for empty content' do
        post :create, params: { 
          chat_room_id: chat_room.id, 
          message: { content: '' } 
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not a member of the chat room' do
      it 'returns not found status' do
        post :create, params: { 
          chat_room_id: chat_room.id, 
          message: { content: 'Hello World' } 
        }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('You are not part of the room')
      end
    end

    context 'when chat room does not exist' do
      it 'returns not found status' do
        post :create, params: { 
          chat_room_id: 999999, 
          message: { content: 'Hello World' } 
        }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Chat room not found')
      end
    end
  end
end
