class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      forwarding_url = session[:forwarding_url]
      reset_session
      remember_me user
      log_in user
      redirect_to forwarding_url || user
    else
      flash.now[:danger] = t(".invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  def remember_me user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
  end
end
