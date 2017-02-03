class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :followings, :followers]
  before_action :correct_user, only: [:edit, :update]
  
  def show
    @user = User.find(params[:id])
    @title = 'Micropost'
    @count = @user.microposts.count
    @microposts = @user.microposts.order(created_at: :desc).page(params[:page])
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
        redirect_to @user # ここを修正
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = "UpdateProfile!"
      redirect_to @user # ここを修正
    else
      render 'edit'
    end
  end
  
  def followings
    @title = 'followings'
    @users = @user.following_users
    render 'show_follow'
  end
  
  def followers
    @title = 'followers'
    @users = @user.follower_users
    render 'show_follow'
  end
  
  def favorites
    @user = User.find(params[:id])
    @title = 'Favorites'
    @count = @user.favorite_microposts.count
    @microposts = @user.favorite_microposts.page(params[:page])
    render 'show'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation,:location)
  end

  def set_user
    @user = User.find(params[:id])
  end
  
  def correct_user
    redirect_to root_path if @user != current_user
  end
end