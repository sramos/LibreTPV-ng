class ClientNotesController < ApplicationController
  before_action :set_note, only: [:show, :show_lines, :update, :destroy]
  before_action :load_clients, only: [:index, :show, :update]

  def index
    @note = ClientNote.new(date: Date.today, client_id: 1)
    @notes = ClientNote.open
  end

  def show_lines
    @note_lines = @note.note_lines
    @turbo_frame_id = params[:turbo_frame]
    render layout: false
  end

  def edit
  end

  def update
    @note ||= ClientNote.new
    if @note.update(note_params)
      redirect_to edit_client_note_path(@note), notice: t('notices.updated', default: 'Client note was successfully updated.')
    else
      flash.now[:alert] = @note.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to client_notes_path, notice: 'Cesta eliminada correctamente' }
      format.turbo_stream { redirect_to client_notes_path, status: :see_other }
    end
  rescue => e
    redirect_to client_notes_path, alert: "Error al eliminar la cesta: #{e.message}"
  end

  private

  def set_note
    @note = ClientNote.find_by(id: params[:id])
    puts "**** Tenemos @note: #{@note.inspect}"
  end

  # Strong parameters for ClientNote
  def note_params
    params.require(:note).permit(:date, :client_id)
  end

  def load_clients
    @clients = Client.active
  end
end
