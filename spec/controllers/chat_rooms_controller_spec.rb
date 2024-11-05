require 'rails_helper'

RSpec.describe ChatRoomsController, type: :controller do
    include JsonWebToken
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:chat_room) { create(:chat_room) }
  let(:token) { jwt_encode(user_id: user.id)}
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST #create' do
    let(:valid_attributes) { { name: 'Test Room', private: false } }
    
    context 'with valid parameters' do
      before do
        chat_room.users << user
      end
      it 'creates a new chat room' do
        post :create, params: { chat_room: valid_attributes }
        expect(JSON.parse(response.body)['message']).to eq('Chat room created successfully')
      end
      
      it 'creates a new chat room if member is added ' do
        post :create, params: { chat_room: valid_attributes, member_ids: [other_user.id].to_json }
        expect(JSON.parse(response.body)['message']).to eq('Chat room created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity status' do
        post :create, params: { chat_room: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:valid_attributes) { { name: 'Test Room1 ' } }
    
    context 'with valid parameters' do
      before do
        chat_room.users << user
      end
      it 'updates a chat room' do
        put :update, params: { id: chat_room.id, chat_room: valid_attributes }
        expect(JSON.parse(response.body)['message']).to eq('Chat room updated successfully')
      end
    end
    
    context 'with invalid parameters' do
      before do
        chat_room.users << user
      end
      it 'returns unprocessable entity status' do
        put :update, params: { id: chat_room.id, chat_room: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid parameters' do
      before do
        chat_room.users << user
      end
      it 'deletes a chat room' do
        delete :destroy, params: { id: chat_room.id }
        expect(JSON.parse(response.body)['message']).to eq('Chat room deleted successfully')
      end
    end
  end

  describe 'GET #show' do
    context 'with valid parameters' do
      before do
        chat_room.users << user
      end
      it 'displays a chat room' do
        get :show, params: { id: chat_room.id }
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #add_member' do
    let!(:chat_room) { create(:chat_room, users: [user]) }

    context 'with valid member_ids' do
      it 'adds new members to the chat room' do
        post :add_member, params: { 
          id: chat_room.id,
          member_ids: [other_user.id].to_json
        }
        expect(chat_room.reload.users).to include(other_user)
        expect(response).to have_http_status(:ok)
      end

      it 'prevents adding multiple users to private chat room' do
        private_room = create(:chat_room, private: true, users: [user, other_user])
        post :add_member, params: {
          id: private_room.id,
          member_ids: [create(:user).id].to_json
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates private chat room name when adding member' do
        private_room = create(:chat_room, private: true, users: [user])
        post :add_member, params: {
          id: private_room.id,
          member_ids: [other_user.id].to_json
        }
        expect(JSON.parse(response.body)["message"]).to eq 'Members added successfully'
        expect(private_room.reload.name).to eq(other_user.full_name)
      end
    end

    context 'with invalid parameters' do
      it 'returns error when member_ids is missing' do
        post :add_member, params: { id: chat_room.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end
end
