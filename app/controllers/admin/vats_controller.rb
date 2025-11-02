module Admin
  class VatsController < ApplicationController
    before_action :set_vat, only: [:edit, :update, :destroy]

    def index
      @vats = Vat.order(:name)
    end

    def edit
    end

    def update
    end

    def destroy
      if @vat.destroy
        msg = 'Tipo de IVA eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el objeto: ' + @vat.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("vat_#{@vat&.id}")
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
      params.require(:vat).permit(:name, :rate)
    end
  end
end