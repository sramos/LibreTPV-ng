module Sales
  class ClientInvoicesController < ApplicationController
    before_action :set_invoice, only: [:edit, :update, :destroy]

    def index
      index_filtered
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'invoices', objects: @invoices.except(:limit, :offset),
                          title: 'Facturas de Venta', filter_scope: filter_scope }
          nom_fich = 'facturas_venta_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @note = ClientNote.find(params[:client_note_id])
      @invoice = ClientInvoice.new(client_id: @note.client_id, date: DateTime.now)
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @note = ClientNote.find(params[:client_note_id])
      @invoice = @note.create_and_pay_invoice(params[:payment_type_id])
      if @invoice && @invoice.errors.blank?
        flash[:ok_message] = "¡Asegúrese de cobrar la venta!: #{@invoice.total_amount}€"
        PrintTicketService.call(@invoice) if params[:print_ticket] == '1'
        redirect_to sales_client_notes_path
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
      if @invoice.update(invoice_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "invoice_#{@invoice.id}",
              stream_locals: { invoice: @invoice },
            )
          end
          format.html { redirect_to sales_invoices_path, notice: 'Factura actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { invoice: @invoice })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @invoice.destroy
        msg = 'Factura eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la factura: ' + @invoice.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "invoice_#{@invoice.id}", message: msg
          )
        end
        format.html { redirect_to sales_invoices_path, notice: msg }
      end
    rescue => e
      redirect_to sales_invoices_path, alert: "Error al eliminar la factura: #{e.message}"
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'],
                         ['Email','email','string'],
                         ['NIF','code_id','string'] ]
      @invoices = Invoice.order(created_at: :desc)
      
      session[filter_scope] ||= {}
      value = session[filter_scope]['value'] if session[filter_scope]
      if value.present?
        case session[filter_scope]['type']
        when 'name'
          @invoices = @invoices.where("name LIKE ?", "%#{value}%")
        when 'email'
          @invoices = @invoices.joins(:contact_info).where("contact_infos.email LIKE ?", "%#{value}%")
        when 'code_id'
          @invoices = @invoices.where("code_id LIKE ?", "%#{value}%")
        end
      end
      @invoices = @invoices.page(params[:page]).per(session[:per_page])
    end
    
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def invoice_params
      params.require(:invoice).permit(:date)
    end
  end
end