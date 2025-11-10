module Sales
  class ClientsController < ApplicationController
    before_action :set_client, only: [:edit, :update, :destroy]

    def index
      @clients = Client.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @client = Client.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @client = Client.new(client_params)
      if @client.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_clients_tag',
              stream_action: :after,
              stream_locals: { client: @client },
              highlight_dom_id: "client_#{@client.id}",
              show_section_id: 'new_clients_section'
            )
          end
          format.html { redirect_to admin_clients_path, notice: 'Cliente creado correctamente' }
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
      if @client.update(client_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "client_#{@client.id}",
              stream_locals: { client: @client },
            )
          end
          format.html { redirect_to sales_clients_path, notice: 'Cliente actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { client: @client })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @client.destroy
        msg = 'Cliente eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el cliente: ' + @client.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("client_#{@client&.id}")
          ]
        end
        format.html { redirect_to sales_clients_path, notice: msg }
      end
    rescue => e
      redirect_to sales_clients_path, alert: "Error al eliminar el cliente: #{e.message}"
    end

    private

    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:name, :active)
    end
  end
end