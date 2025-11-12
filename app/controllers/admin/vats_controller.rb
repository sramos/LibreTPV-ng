module Admin
  class VatsController < ApplicationController
    before_action :set_vat, only: [:edit, :update, :destroy]

    def index
      @vats = Vat.order(:name).page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'vats', objects: @vats.except(:limit, :offset),
                          title: 'Tipos de IVA'}
          nom_fich = 'ivas_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @vat = Vat.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @vat = Vat.new(vat_params)
      if @vat.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_vats_tag',
              stream_action: :after,
              stream_locals: { vat: @vat },
              highlight_dom_id: "vat_#{@vat.id}",
              show_section_id: 'new_vats_section'
            )
          end
          format.html { redirect_to admin_vats_path, notice: 'Tipo de IVA creado correctamente' }
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
      if @vat.update(vat_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "vat_#{@vat.id}",
              stream_locals: { vat: @vat },
            )
          end
          format.html { redirect_to admin_vats_path, notice: 'Tipo de IVA actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { vat: @vat })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @vat.destroy
        msg = 'Tipo de IVA eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el tipo de IVA: ' + @vat.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("vat_#{@vat.id}")
          ]
        end
        format.html { redirect_to admin_vats_path, notice: msg }
      end
    rescue => e
      redirect_to admin_vats_path, alert: "Error al eliminar el tipo de IVA: #{e.message}"
    end

    private

    def set_vat
      @vat = Vat.find(params[:id])
    end

    def vat_params
      params.require(:vat).permit(:name, :rate_value, :active)
    end
  end
end