# frozen_string_literal: true

# Example controller usage

class UsersController < ApplicationController
  # Standard Rails controller actions work automatically
  # because to_param is overridden to use public_id

  def show
    # Method 1: Use the overridden find method
    # Accepts both internal ID and public_id
    @user = User.find(params[:id])

    # Method 2: Explicitly use find_by_public_id
    # @user = User.find_by_public_id(params[:id])

    # Method 3: Use the controller helper (accepts both formats)
    # @user = find_by_any_id!(User, params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      # Automatically redirects to /users/:public_id
      redirect_to @user, notice: "User updated"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

# API controller example
class Api::V1::UsersController < Api::V1::BaseController
  def show
    # Controller helper is great for APIs
    @user = find_by_any_id!(User, params[:id])
    render json: @user
  end

  def lookup
    # Can mix internal and public IDs in the same endpoint
    users = params[:ids].map { |id| find_by_any_id(User, id) }.compact
    render json: users
  end
end
