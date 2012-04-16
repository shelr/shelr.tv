class ApplicationController < ActionController::Base

  helper_method :current_user, :logged_in?, :redirect_to_target_or_default

  protect_from_forgery

  private

  def current_user
    @current_user ||= UserDecorator.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user
  end

  def login_required
    unless logged_in?
      flash[:error] = "You must first log in or sign up before accessing this page."
      store_target_location
      redirect_to login_url
    end
  end

  def redirect_to_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def store_target_location
    session[:return_to] = request.fullpath
  end

end
