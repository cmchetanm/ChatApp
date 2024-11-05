class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content
  
  belongs_to :user
  belongs_to :chat_room
  
  attribute :channel_members do
    object.chat_room.users.map do |user|
      {
        id: user.id,
        full_name: user.full_name,
        status: user.status
      }
    end
  end
end
