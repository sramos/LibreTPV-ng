module Products
  class SupplierNoteLinesController < ApplicationController
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
                          title: 'Productos del albaran', filter_scope: filter_scope }
          nom_fich = 'productos_albaran_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.turbo_stream
      end
    end

    def create_by_concept
      note_line = ClientNoteLine.new(note_id: @note.id)
      if note_line.update(note_line_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream:
              helpers.update_object_turbo_stream(
                container_dom_id: "note_#{@note.id}_new_note_line_tag",
                stream_action: :after,
                stream_locals: { note: @note, note_line: note_line },
                highlight_dom_id: "note_line_#{note_line.id}") +
              [
                turbo_stream.replace("note_#{@note.id}_side", partial: 'sales/client_notes/form_side')
              ]
          end
        end
      else
        Rails.logger.error "[Products::NoteLinesController#create_by_concept] Error al crear la linea de albarán: #{note_line.errors.inspect}"
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
            ]
          end
        end
      end      
    end

    def create_by_code
      product_code = params[:note_line][:product_code].delete('-') if params[:note_line].present?
      product = Product.find_by(code: product_code)
      if product.nil? && params[:product_data].present?
        product = Product.create_from_json(JSON.parse(params[:product_data]))
      end

      if product && product.errors.blank?
        note_line = ClientNoteLine.new(note_id: @note.id, product: product)
        if note_line.update(note_line_params)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream:
                helpers.update_object_turbo_stream(
                  container_dom_id: "note_#{@note.id}_new_note_line_tag",
                  stream_action: :after,
                  stream_locals: { note: @note, note_line: note_line },
                  highlight_dom_id: "note_line_#{note_line.id}") +
                [
                  turbo_stream.replace("note_#{@note.id}_side", partial: 'sales/client_notes/form_side')
                ]
            end
          end
        else
          puts "***** Partimos del producto #{product.inspect}"
          puts "***** y vamos a actualizar con los parámetros #{note_line_params.inspect}"
          Rails.logger.error "[Products::NoteLinesController#create_by_code] Error al crear la linea de albarán: #{note_line.errors.inspect}"
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: [
                turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
              ]
            end
          end
        end
      # If product is not in stock
      else
        # TODO: Check if product exists and has no errors
        # TODO: Check product service response
        result = FindProductService.call(product_code)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'product_by_code_not_found',
              stream_partial: 'product_by_code_not_found',
              stream_locals: { note_line: @note_line, payload: result.payload },
              message: nil
            )
          end
        end
      end
    end

    def create_by_name
      product = Product.find_by(name: params[:note_line][:product_name]) if params[:note_line].present?
      note_line = ClientNoteLine.new(note_id: @note.id, product: product)
      if product && note_line.update(note_line_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream:
              helpers.update_object_turbo_stream(
                container_dom_id: "note_#{@note.id}_new_note_line_tag",
                stream_action: :after,
                stream_locals: { note: @note, note_line: note_line },
                highlight_dom_id: "note_line_#{note_line.id}") +
              [
                turbo_stream.replace("note_#{@note.id}_side", partial: 'sales/client_notes/form_side')
              ]
          end
        end
      else
        Rails.logger.error "[Products::NoteLinesController#create_by_name] Error al crear la linea de albarán: #{note_line.errors.inspect}"
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
            ]
          end
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
          render turbo_stream:
            helpers.remove_object_turbo_stream(
              container_dom_id: "note_line_#{@note_line.id}", message: msg
            ) + [
              turbo_stream.replace(
                'importe_total',
                partial: 'products/supplier_notes/total_cost',
                locals: { note: @note }
              )
            ]
        end
        format.html { redirect_to sales_note_path(@note), notice: msg }
      end
    rescue => e
      redirect_to sales_note_path(@note), alert: "Error al eliminar la linea de albarán: #{e.message}"
    end

    private

    def set_note
      @note = SupplierNote.find(params[:supplier_note_id])
    end
    
    def set_note_line
      @note_line = @note.note_lines.find(params[:id])
    end

    def form_values
    end
    
    def note_line_params
      params.require(:note_line).permit(:quantity, :discount_value,
                                        :product_name, :product_price,
                                        :product_vat)
    end
  end
end