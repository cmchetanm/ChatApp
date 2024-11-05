# frozen_string_literal: true

# Messages Controller
class MessagesController < ApiController
  before_action :find_chat_room, :check_membership

  # POST /chat_rooms/:chat_room_id/messages
  def create
    message = @chat_room.messages.new(message_params.merge(user: current_user))

    if message.save
      render json: { message: MessageSerializer.new(message), status: :created}
    else
      render json: { error: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Find chat room
  def find_chat_room
    @chat_room = ChatRoom.find_by_id(params[:chat_room_id])
    render json: { error: 'Chat room not found' }, status: :not_found unless @chat_room
  end

  # Check membership
  def check_membership
    return if @chat_room.users.include?(current_user)

    render json: { error: 'You are not part of the room' },
           status: :not_found
  end

  # Message params
  def message_params
    params.require(:message).permit(:content)
  end
end
