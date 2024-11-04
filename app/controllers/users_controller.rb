# frozen_string_literal: true

# Users Authentication
class UsersController < ApiController
  before_action :authenticate_user, except: %i[login register]

  # POST /register
  def register
    @user = User.new(user_params)
    if @user.save
      token = jwt_encode(user_id: @user.id)
      render json: {
        message: 'User created successfully',
        user: UserSerializer.new(@user),
        token: token
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      render json: {
        message: 'User logged in successfully',
        user: UserSerializer.new(@user),
        token: token
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # POST /password_reset
  def password_reset
    if current_user.update(password: params[:password])
      return render json: { error: 'Password reset successfully' },
                    status: :ok
    end
  end

  private

  # Permit user params
  def user_params
    params.permit(:email, :password, :full_name)
  end
end
