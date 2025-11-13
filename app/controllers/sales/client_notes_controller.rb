module Sales
  class ClientNotesController < ApplicationController
    before_action :set_note, only: [:edit, :update, :destroy]

    def index
      @note = ClientNote.new(date: Date.today, client_id: Client.first.id)
      @notes = ClientNote.open.order(date: :desc).page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'client_notes', objects: @notes.except(:limit, :offset),
                          title: 'Albaranes de Venta' }
          nom_fich = 'albaranes_cliente_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @note = ClientNote.create(note_params)
      @note_lines = @note.note_lines
    end

    def create
      @note = ClientNote.new(note_params)
      if @note.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_notes_tag',
              stream_action: :after,
              stream_locals: { note: @note },
              highlight_dom_id: "note_#{@note.id}",
              show_section_id: 'new_notes_section'
            )
          end
          format.html { redirect_to sales_client_notes_path, notice: 'Nota creada correctamente' }
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
      @note_lines = @note.note_lines
    end

    def update
      if @note.update(note_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "note_#{@note.id}",
              stream_locals: { note: @note },
            )
          end
          format.html { redirect_to sales_client_notes_path, notice: 'Nota actualizada correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { note: @note })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @note.destroy
        msg = 'Nota eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la nota: ' + @note.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("client_note_#{@note&.id}")
          ]
        end
        format.html { redirect_to sales_client_notes_path, notice: msg }
      end
    rescue => e
      redirect_to sales_client_notes_path, alert: "Error al eliminar la nota: #{e.message}"
    end

    private

    def set_note
      @note = ClientNote.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:date, :client_id)
    end
  end
end