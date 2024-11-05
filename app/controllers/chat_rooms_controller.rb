# frozen_string_literal: true

# Chat Rooms Controller
class ChatRoomsController < ApiController
  before_action :find_chat_room, only: %i[update show destroy add_member]

  # POST /chat_rooms
  def create
    @chat_room = ChatRoom.new(chat_room_params)
    if @chat_room.save
      @chat_room.users << current_user
      return handle_members(params[:member_ids], 'created') if params[:member_ids].present?

      handle_response(true, 'created')
    else
      handle_response
    end
  end

  # PATCH /chat_rooms
  def update
    return render json: { error: 'Room type cannot be udated!!' } if chat_room_params['private'].present?
    return render json: { error: 'Private room cannot be udated!!' } if @chat_room.private

    if @chat_room.update(chat_room_params)
      handle_response(true, 'updated')
    else
      handle_response
    end
  end

  # DELETE /chat_rooms
  def destroy    
    handle_response(true, 'deleted') if @chat_room.destroy
  end

  # SHOW /chat_rooms
  def show
    render json: { chat_room: @chat_room }, status: :ok
  end

  # POST /chat_rooms/:id/add_member
  def add_member
    return handle_members(params[:member_ids], 'added') if params[:member_ids].present?

    render json: { error: 'User not found' }, status: :unprocessable_entity
  end

  private

  # Find Chat Room
  def find_chat_room
    
    @chat_room = ChatRoom.find_by_id(params[:id])
    return render json: { error: 'Chat Room not found!!' } unless @chat_room.present?

    render json: { error: 'You are not part of this chat room!!' } unless @chat_room.users.include?(current_user)
  end

  # Handle response
  def handle_response(status = false, msg = '')
    if status
      render json: { chat_room: ChatRoomSerializer.new(@chat_room), message: "Chat room #{msg} successfully" },
             status: :ok
    else
      render json: { error: @chat_room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Handle members
  def handle_members(member_ids, msg)
    members = JSON.parse(member_ids)
    return handle_private_room_error if @chat_room.private && @chat_room.users.count == 2

    update_chat_room_name(members) if @chat_room.private
    members.each { |member_id| add_user_to_chat_room(member_id) }

    if msg == 'created'
      return render json: { chat_room: ChatRoomSerializer.new(@chat_room), message: 'Chat room created successfully' },
                    status: :ok
    end

    render json: { chat_room: ChatRoomSerializer.new(@chat_room), message: "Members #{msg} successfully" }, status: :ok
  end

  # Handle private room
  def handle_private_room_error
    render json: { error: 'Cannot add more than one user to private channel' }, status: :unprocessable_entity
    nil
  end

  # Update chat room name
  def update_chat_room_name(member_ids)
    user_name = User.find_by_id(member_ids.first)&.full_name
    @chat_room.update(name: user_name) if user_name
  end

  # Add user to chat room
  def add_user_to_chat_room(member_id)
    user = User.find_by_id(member_id)
    @chat_room.users << user if user && !@chat_room.users.include?(user)
  end

  # Chat room params
  def chat_room_params
    params.require(:chat_room).permit(:name, :private)
  end
end
