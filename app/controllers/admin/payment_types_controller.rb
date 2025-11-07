module Admin
  class PaymentTypesController < ApplicationController
    before_action :set_payment_type, only: [:edit, :update, :destroy]

    def index
      @payment_types = PaymentType.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @payment_type = PaymentType.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @payment_type = PaymentType.new(payment_type_params)
      if @payment_type.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_payment_types_tag',
              stream_action: :after,
              stream_locals: { payment_type: @payment_type },
              highlight_dom_id: "payment_type_#{@payment_type.id}",
              show_section_id: 'new_payment_types_section'
            )
          end
          format.html { redirect_to admin_payment_types_path, notice: 'Forma de pago creada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', partial: 'form', locals: { payment_type: @payment_type })
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
      if @payment_type.update(payment_type_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "payment_type_#{@payment_type.id}",
              stream_locals: { payment_type: @payment_type },
            )
          end
          format.html { redirect_to admin_payment_types_path, notice: 'Forma de pago actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { payment_type: @payment_type })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @payment_type.destroy
        msg = 'Forma de pago eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la forma de pago: ' + @payment_type.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("payment_type_#{@payment_type.id}")
          ]
        end
        format.html { redirect_to admin_payment_types_path, notice: msg }
      end
    rescue => e
      redirect_to admin_payment_types_path, alert: "Error al eliminar la forma de pago: #{e.message}"
    end

    private

    def set_payment_type
      @payment_type = PaymentType.find(params[:id])
    end

    def payment_type_params
      params.require(:payment_type).permit(:name, :cash, :active)
    end
  end
end