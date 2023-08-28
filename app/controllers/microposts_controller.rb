class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    attach_image
    if @micropost.save
      flash[:success] = t(".success")
      redirect_to root_path
    else
      @pagy, @feed_items = pagy(current_user.feed.newest,
                                items: Settings.digits.per_page_10)
      render "static_pages/home", status: :unprocessable_entity
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".fail")
    end
    redirect_to request.referer, status: :see_other
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
  end

  def attach_image
    @micropost.image.attach params.dig(:micropost, :image)
  end
end
