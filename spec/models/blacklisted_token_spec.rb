require 'rails_helper'

RSpec.describe BlacklistedToken, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      blacklisted_token = BlacklistedToken.new(
        token: 'valid_token_string',
        exp: Time.current + 1.day
      )
      expect(blacklisted_token).to be_valid
    end

    it 'is invalid without a token' do
      blacklisted_token = BlacklistedToken.new(exp: Time.current + 1.day)
      expect(blacklisted_token).to_not be_valid
      expect(blacklisted_token.errors[:token]).to include("can't be blank")
    end

    it 'is invalid without an expiration time' do
      blacklisted_token = BlacklistedToken.new(token: 'valid_token_string')
      expect(blacklisted_token).to_not be_valid
      expect(blacklisted_token.errors[:exp]).to include("can't be blank")
    end

    it 'can be created with valid attributes' do
      expect {
        BlacklistedToken.create!(
          token: 'valid_token_string',
          exp: Time.current + 1.day
        )
      }.to change(BlacklistedToken, :count).by(1)
    end

    it 'can store different token values' do
      token1 = BlacklistedToken.create!(
        token: 'token_1',
        exp: Time.current + 1.day
      )
      token2 = BlacklistedToken.create!(
        token: 'token_2',
        exp: Time.current + 1.day
      )
      
      expect(BlacklistedToken.count).to eq(2)
      expect(BlacklistedToken.pluck(:token)).to contain_exactly('token_1', 'token_2')
    end
  end
end
