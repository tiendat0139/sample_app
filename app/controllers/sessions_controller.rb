class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      reset_session
      params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
      log_in user
      redirect_to user
    else
      flash.now[:danger] = t(".invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end