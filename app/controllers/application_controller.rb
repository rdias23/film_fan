class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery
  before_filter :authenticate
  before_filter :configure_permitted_parameters, if: :devise_controller?

  private
  def authenticate
    @auth = (user_signed_in?) ? User.find(current_user) : nil
  end

  def check_if_logged_in
    redirect_to(root_path) if @auth.nil?
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name) }
  end 

end
