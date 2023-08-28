class UsersController < ApplicationController
  before_action :set_user, except: %i(create index new)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @pagy, @users = pagy(User.all, items: Settings.digits.per_page_10)
  end

  def show
    @pagy, @microposts = pagy(@user.microposts.newest,
                              items: Settings.digits.per_page_10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t(".info")
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".fail")
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(:name, :email,
                                 :password, :password_confirmation)
  end

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t(".user_not_found")
    redirect_to root_path
  end

  def correct_user
    redirect_to root_path, status: :see_other unless current_user? @user
  end

  def admin_user
    redirect_to(root_path, status: :see_other) unless current_user.admin?
  end
end
