# frozen_string_literal: true

# Message model
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room
  validates :content, presence: true

  after_create_commit { broadcast_message }

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_room_#{chat_room.id}", {
                                   id: id,
                                   content: content,
                                   user_id: user.id,
                                   user_name: user.email,
                                   created_at: created_at.strftime('%H:%M:%S')
                                 })
  end
end
