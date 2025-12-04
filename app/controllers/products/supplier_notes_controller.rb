module Products
  class SupplierNotesController < ApplicationController
    before_action :set_note, only: [:edit, :update, :destroy]

    def index
      @note = SupplierNote.new(date: Date.today, supplier_id: nil)
      @notes = SupplierNote.open.order(date: :desc).page(params[:page]).per(session[:per_page])
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'supplier_notes', objects: @notes.except(:limit, :offset),
                          title: 'Albaranes de Compra' }
          nom_fich = 'albaranes_recepcion_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @note = SupplierNote.create(note_params)
      puts "***** Manejando el objeto @note: #{@note.errors.inspect}"
      @note_lines = @note.note_lines
    end

    # For supplier notes, purchase product price of a book is sell price without vat
    # and discount is applied to this base price, not full price.
    def create
      @note = SupplierNote.new(note_params)
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
          format.html { redirect_to products_supplier_notes_path, notice: 'Nota creada correctamente' }
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
      @note_lines = @note.note_lines.order(created_at: :desc)
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
          format.html { redirect_to products_supplier_notes_path, notice: 'Nota actualizada correctamente' }
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
        msg = 'Cesta de venta eliminada correctamente'
      else
        msg = 'Se han producido errores eliminando la cesta de venta: ' + @note.errors.inspect
      end
      # If coming from edit page with redirect flag, force full redirect to index
      if params[:redirect].present?
        flash[:ok_message_fade] = msg
        return redirect_to products_supplier_notes_path
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "supplier_note_#{@note.id}", message: msg
          )
        end
        format.html do
          flash[:ok_message_fade] = msg
          redirect_to products_supplier_notes_path
        end
      end
    rescue => e
      redirect_to products_supplier_notes_path, alert: "Error al eliminar la nota: #{e.message}"
    end

    private

    def set_note
      @note = SupplierNote.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:date, :code, :deposit, :supplier_id)
    end
  end
end