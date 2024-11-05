require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include JsonWebToken
  let(:user) { create(:user) }
  let(:token) { jwt_encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST #register' do
    let(:valid_params) { { email: 'test@example.com', password: 'password123', full_name: 'Test User' } }

    it 'creates a new user with valid parameters' do
      post :register, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['message']).to eq('User created successfully')
    end

    it 'returns error with invalid parameters' do
      post :register, params: { email: 'invalid', password: 'short', full_name: '' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #login' do
    before do
      user.update(password: 'password123')
    end

    it 'logs in user with valid credentials' do
      post :login, params: { email: user.email, password: 'password123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('User logged in successfully')
      expect(user.reload.status).to eq('online')
    end

    it 'returns error with invalid credentials' do
      post :login, params: { email: user.email, password: 'wrong_password' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #password_reset' do
    it 'updates password successfully' do
      post :password_reset, params: { password: 'newpassword123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['error']).to eq('Password reset successfully')
    end
  end

  describe 'POST #logout' do
    it 'logs out user successfully' do
      post :logout
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('User logged out successfully')
      expect(user.reload.status).to eq('offline')
      expect(BlacklistedToken.last.token).to eq(token)
    end
  end

  describe 'GET #check_status' do
    it 'returns user status when user exists' do
      get :check_status, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['msg']).to eq("The user status is: #{user.status}")
    end

    it 'returns not found when user does not exist' do
      get :check_status, params: { id: 999999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('User not found')
    end
  end
end
