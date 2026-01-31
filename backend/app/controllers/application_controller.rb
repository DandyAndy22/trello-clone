class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    begin
      header = request.headers['Authorization']
      token = header.split(' ').last if header
      
      unless token
        render json: { error: 'Not Authorized' }, status: :unauthorized
        return
      end
      
      decoded = JsonWebToken.decode(token)
      
      if decoded
        @current_user = User.find_by(id: decoded[:user_id])
      else
        render json: { error: 'Not Authorized' }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, ArgumentError, TypeError
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end
end
