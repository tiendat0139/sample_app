class SessionsController < ApplicationController
  before_action :find_user, only: :create
  before_action :authenticate_user, only: :create

  def new; end

  def create
    if @user.activated
      forwarding_url = session[:forwarding_url]
      reset_session
      remember_me @user
      log_in @user
      redirect_to forwarding_url || @user
    else
      flash[:warning] = t(".not_activated")
      redirect_to root_path
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  def remember_me user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
  end

  private

  def find_user
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user

    login_failed
  end

  def authenticate_user
    return if @user.authenticate params.dig(:session, :password)

    login_failed
  end

  def login_failed
    flash.now[:danger] = t(".invalid")
    render :new, status: :unprocessable_entity
  end
end
