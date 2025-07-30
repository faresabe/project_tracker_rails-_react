class ApplicationController < ActionController::API
  

  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from JWT::DecodeError, with: :unauthorized_response
  rescue_from JWT::ExpiredSignature, with: :unauthorized_response

  attr_reader :current_user 

  private

  
  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header&.start_with?('Bearer ')

    unless token
      render json: { error: 'Token not provided' }, status: :unauthorized
      return
    end

    decoded_token = JsonWebToken.decode(token)

    unless decoded_token
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
      return
    end

    @current_user = User.find(decoded_token[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :unauthorized
  rescue StandardError => e 
    Rails.logger.error "Authentication error: #{e.message}"
    render json: { error: 'Authentication failed' }, status: :internal_server_error
  end

 
  def not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def bad_request_response(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def unauthorized_response(exception)
    render json: { error: exception.message }, status: :unauthorized
  end
end
