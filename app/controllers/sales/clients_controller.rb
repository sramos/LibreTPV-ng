module Sales
  class ClientsController < ApplicationController
    before_action :set_client, except: [:index, :new, :create]

    def index
      index_filtered
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'clients', objects: @clients.except(:limit, :offset),
                          title: 'Clientes', filter_scope: filter_scope }
          nom_fich = 'clientes_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
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
          format.html { redirect_to sales_clients_path, notice: 'Cliente creado correctamente' }
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
      @client.update(client_params) if params[:client]
      if @client.errors.empty?
        ClientCreditIncrementService.call(@client, params[:credit].to_f) if params[:credit]
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
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "client_#{@client.id}", message: msg
          )
        end
        format.html { redirect_to sales_clients_path, notice: msg }
      end
    rescue => e
      redirect_to sales_clients_path, alert: "Error al eliminar el cliente: #{e.message}"
    end

    def add_credit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def invoice_products
      @lines = @client.note_lines.page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'client_invoice_products', objects: @lines.except(:limit, :offset),
                          title: 'Productos vendidos' }
          nom_fich = 'productos_vendidos_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'],
                         ['Email','email','string'],
                         ['NIF','code_id','string'] ]
      @clients = Client.order(:name)
      
      session[filter_scope] ||= {}
      value = session[filter_scope]['value'] if session[filter_scope]
      if value.present?
        case session[filter_scope]['type']
        when 'name'
          @clients = @clients.where("name LIKE ?", "%#{value}%")
        when 'email'
          @clients = @clients.joins(:contact_info).where("contact_infos.email LIKE ?", "%#{value}%")
        when 'code_id'
          @clients = @clients.where("code_id LIKE ?", "%#{value}%")
        end
      end
      @clients = @clients.page(params[:page]).per(session[:per_page])
    end
    
    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:name, :active, :is_b2b,
                                     :credit, :code_id, :discount)
    end
  end
end