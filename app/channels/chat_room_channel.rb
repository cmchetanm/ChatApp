# app/channels/chat_room_channel.rb

class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    chat_room = ChatRoom.find(params[:room])
    stream_from "chat_room_#{chat_room.id}"
  end

end
