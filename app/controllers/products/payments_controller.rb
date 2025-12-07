module Sales 
  class PaymentsController < ApplicationController
    before_action :set_invoice
    before_action :set_payment, only: [:edit, :update, :destroy]

    def index
      @payments = @invoice.payments.page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.html { render layout: false }
        format.xlsx do
          @xlsx_output = {type: 'payments', objects: @payments.except(:limit, :offset),
                          title: 'Pagos', filter_scope: filter_scope }
          nom_fich = 'pagos_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.turbo_stream
      end
    end

    def new
      @payment = @invoice.payments.new(date: DateTime.now, amount: @invoice.pending_payment)
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @payment = @invoice.payments.new(payment_params)
      if @payment.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "invoice_#{@invoice.id}_new_payment_tag",
              stream_action: :after,
              stream_locals: { payment: @payment },
              highlight_dom_id: "payment_#{@payment.id}"
            )
          end
          format.html { redirect_to admin_suppliers_path, notice: 'Proveedor creado correctamente' }
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
      if @payment.update(payment_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "payment_#{@payment.id}",
              stream_locals: { payment: @payment },
            )
          end
          format.html { redirect_to sales_invoices_path, notice: 'Pago actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { payment: @payment })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @payment.destroy
        msg = 'Pago eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el pago ' + @payment.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "payment_#{@payment.id}", message: msg
          )
        end
        format.html { redirect_to sales_invoices_path, notice: msg }
      end
    rescue => e
      redirect_to sales_invoices_path, alert: "Error al eliminar el pago: #{e.message}"
    end

    private

    def set_invoice
      @invoice = ClientInvoice.find(params[:client_invoice_id])
    end
    
    def set_payment
      @payment = @invoice.payments.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :date, :payment_type_id)
    end
  end
end