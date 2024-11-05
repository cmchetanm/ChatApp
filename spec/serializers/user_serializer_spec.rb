require 'rails_helper'

RSpec.describe UserSerializer do
  let(:user) { create(:user, email: 'test@example.com', full_name: 'Test User', status: 'active') }
  let(:serializer) { described_class.new(user) }

  describe '#serialized_json' do
    let(:serialized_user) { JSON.parse(serializer.to_json) }

    it 'includes the correct attributes' do
      expect(serialized_user.keys).to match_array(['id', 'email', 'status', 'full_name'])
    end

    it 'has the correct values for all attributes' do
      expect(serialized_user['id']).to eq(user.id)
      expect(serialized_user['email']).to eq('test@example.com')
      expect(serialized_user['full_name']).to eq('Test User')
      expect(serialized_user['status']).to eq('active')
    end

    it 'handles nil values correctly' do
      user.full_name = nil
      expect(serialized_user['full_name']).to be_nil
    end

    it 'handles empty string values' do
      user.full_name = ''
      expect(serialized_user['full_name']).to eq('')
    end

    it 'serializes user with special characters in attributes' do
      user.full_name = 'Test@User#123'
      expect(serialized_user['full_name']).to eq('Test@User#123')
    end
  end
end
