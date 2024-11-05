require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  
  before do
    cookies.signed[:user_id] = user.id
  end

  describe '#connect' do
    it 'successfully connects with valid user id in cookies' do
      connect
      expect(connection.current_user).to eq(user)
    end
  end

  describe '#find_verified_user' do
    context 'when user is not found' do
      before do
        cookies.signed[:user_id] = -1
      end

      it 'rejects unauthorized connection' do
        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end

    context 'when cookie is not set' do
      before do
        cookies.signed[:user_id] = nil
      end

      it 'rejects unauthorized connection' do
        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end

    context 'when user is deleted after cookie was set' do
      before do
        cookies.signed[:user_id] = user.id
        user.destroy
      end

      it 'rejects unauthorized connection' do
        expect { connect }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
      end
    end
  end
end
