# frozen_string_literal: true

# ChatRoom model
class ChatRoom < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :chat_room_memberships, dependent: :destroy
  has_many :users, through: :chat_room_memberships
  validates :name, presence: true
end
