class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [:login, :signup]

  def signup
    #debugger
    user = User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: { id: user.id, email: user.email, name: user.name }
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: { id: user.id, email: user.email, name: user.name }
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:authentication).permit(:name, :email, :password, :password_confirmation)
  end
end