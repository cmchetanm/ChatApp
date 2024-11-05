class ChatRoomSerializer < ActiveModel::Serializer
    attributes :id, :name, :private
    
    has_many :users, through: :chat_room_memberships
    
    def users
      object.users.map do |user|
        {
          id: user.id,
          email: user.email,
          full_name: user.full_name
        }
      end
    end
  end