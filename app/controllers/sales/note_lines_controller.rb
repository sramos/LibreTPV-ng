module Sales
  class NoteLinesController < ApplicationController
    before_action :set_note
    before_action :set_note_line, only: [:edit, :update, :destroy]
    before_action :form_values, only: [:edit]

    def index
      @note_lines = @note.note_lines.page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.html { render layout: false }
        format.xlsx do
          @xlsx_output = {type: 'note_lines', objects: @note_lines.except(:limit, :offset),
                          title: 'Productos de venta', filter_scope: filter_scope }
          nom_fich = 'productos_venta_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.turbo_stream
      end
    end

    def edit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def update
      if @note_line.update(note_line_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "note_line_#{@note_line.id}",
              stream_locals: { note_line: @note_line },
            )
          end
          format.html { redirect_to sales_note_path(@note), notice: 'Linea de albarán actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { note_line: @note_line })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @note_line.destroy
        msg = 'Linea de albarán eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la linea de albarán: ' + @note_line.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("note_line_#{@note_line&.id}")
          ]
        end
        format.html { redirect_to sales_note_path(@note), notice: msg }
      end
    rescue => e
      redirect_to sales_note_path(@note), alert: "Error al eliminar la linea de albarán: #{e.message}"
    end

    private

    def set_note
      @note = Note.find(params[:note_id])
    end
    
    def set_note_line
      @note_line = @note.note_lines.find(params[:id])
    end

    def form_values
    end
    
    def note_line_params
      params.require(:note_line).permit(:product_id, :quantity, :price)
    end
  end
end