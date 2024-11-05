require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  include JsonWebToken
  
  controller do
    def index
      render json: { message: 'success' }
    end
  end

  let(:user) { create(:user) }
  let(:token) { jwt_encode(user_id: user.id) }
  let(:invalid_token) { 'invalid_token' }
  let(:expired_token) { jwt_encode({ user_id: user.id, exp: 1.day.ago.to_i }) }

  describe '#authenticate_user' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
      end

      it 'sets current_user' do
        expect(controller.current_user).to eq(user)
      end

      it 'allows the request to proceed' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid token format' do
      before do
        request.headers['Authorization'] = invalid_token
        get :index
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to eq('Unauthorized access')
      end
    end

    context 'with expired token' do
      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :index
      end
    end

    context 'with non-existent user' do
      before do
        token = jwt_encode(user_id: 999999)
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
      end

      it 'returns user not found error' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to eq('User Not Found')
      end
    end

    context 'without authorization header' do
      before do
        get :index
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to eq('Unauthorized access')
      end
    end
  end
end
