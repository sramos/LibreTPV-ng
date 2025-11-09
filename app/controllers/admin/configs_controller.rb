module Admin
  class ConfigsController < ApplicationController
    before_action :set_config, only: [:edit, :update]

    def index
      @configs = Config.order(:name).page(params[:page]).per(session[:per_page])
    end

    def edit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def update
      if @config.update(config_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "config_#{@config.id}",
              stream_locals: { config: @config },
            )
          end
          format.html { redirect_to admin_configs_path, notice: 'Configuración actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { config: @config })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    private

    def set_config
      @config = Config.find(params[:id])
    end

    def config_params
      params.require(:config).permit(:name, :value)
    end
  end
end