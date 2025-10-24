class NoteLinesController < ApplicationController
  before_action :set_note, only: [:index, :show, :create, :update, :destroy]
  before_action :set_note_line, only: [:show, :update, :destroy]

  def index
    @note_lines = @note.note_lines
  end

  def show
  end

  def create
    @note_line = @note.note_lines.build(note_line_params)
    if @note_line.save
      redirect_to note_line_url(@note, @note_line), notice: "Nota de cliente creada exitosamente."
    else
      render :new
    end
  end

  def update
    if @note_line.update(note_line_params)
      redirect_to note_line_url(@note, @note_line), notice: "Nota de cliente actualizada exitosamente."
    else
      render :edit
    end
  end

  def destroy
    line_id = @note_line.id
    @note_line.destroy
    @note.reload
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("#{params[:update]}_line_#{line_id}"),
          turbo_stream.replace('importe_total', partial: 'client_notes/importe_total')
        ]
      end
      format.html { redirect_to client_note_path(@note), notice: 'Línea eliminada exitosamente.' }
    end
  end

private
  def note_line_params
    params.require(:note_line).permit(:note_id, :product_id, :quantity, :price)
  end

  def set_note
    @note = ClientNote.find_by(id: params[:client_note_id] || params[:note_id])
  end

  def set_note_line
    @note_line = @note.note_lines.find_by(id: params[:id])
  end
end
