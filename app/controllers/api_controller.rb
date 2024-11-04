# frozen_string_literal: true

# app/controllers/application_controller.rb

class ApiController < ActionController::API
  include JsonWebToken

  before_action :authenticate_user

  attr_reader :current_user

  private

  # Check for a valid token and identify the current user
  def authenticate_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = jwt_decode(header)
    @current_user = User.find_by_id(decoded[:user_id])
    render json: { errors: 'User Not Found' }, status: :unauthorized and return unless @current_user
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, NoMethodError
    render json: { errors: 'Unauthorized access' }, status: :unauthorized
  end
end
