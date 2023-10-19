module Api
  module V1
    class UsersController < ApplicationController
      def index
        render status: 200, json: {
          success: true,
          data: User.all.select(:id, :email, :username).as_json
        }
      end

      def create
        user = User.new(permitted_params)
        if user.valid? && user.save
          render_success(user)
        else
          render_error(user.errors.messages)
        end
      end

      def login
        user = User.where(email: permitted_params[:email], password: permitted_params[:password]).first
        if user
          render_success(user)
        else
          render status: 401, json: {
            success: false,
            error:  "No user found with these details"
          }
        end
      end

      private def render_success(user)
        render status: 200, json: {
          success: true,
          data: {
            user: {
              email: user.email,
              username: user.username,
            }
          }
        }
      end

      private def render_error(errors)
        render status: 422, json: {
          success: false,
          data: {
            errors: errors.map {|k, v| { field: k, message: v} }
          }
        }
      end

      private def permitted_params
        params.require(:user).permit(:email, :password, :username)
      end
    end
  end
end
