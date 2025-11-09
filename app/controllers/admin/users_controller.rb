module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @user = User.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @user = User.new(user_params)
      if @user.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_users_tag',
              stream_action: :after,
              stream_locals: { user: @user },
              highlight_dom_id: "user_#{@user.id}",
              show_section_id: 'new_users_section'
            )
          end
          format.html { redirect_to admin_users_path, notice: 'Usuario creado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
            ]
          end
          format.html { render :new, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def update
      if @user.update(user_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "user_#{@user.id}",
              stream_locals: { user: @user },
            )
          end
          format.html { redirect_to admin_users_path, notice: 'Usuario actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { user: @user })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @user.destroy
        msg = 'Usuario eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el usuario: ' + @user.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("user_#{@user&.id}")
          ]
        end
        format.html { redirect_to admin_users_path, notice: msg }
      end
    rescue => e
      redirect_to admin_users_path, alert: "Error al eliminar el usuario: #{e.message}"
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :active)
    end
  end
end