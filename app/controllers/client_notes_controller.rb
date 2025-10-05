class ClientNotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :load_clients, only: [:new, :edit, :create, :update]

  def index
    @notes = ClientNote.where(closed: false)
  end

  def show
  end

  def new
    @note = ClientNote.new(date: Date.today)
  end

  def create
    @note = ClientNote.new(note_params)
    if @note.save
      redirect_to edit_client_note_path(@note), notice: t('notices.created', default: 'Client note was successfully created.')
    else
      flash.now[:alert] = @note.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to edit_client_note_path(@note), notice: t('notices.updated', default: 'Client note was successfully updated.')
    else
      flash.now[:alert] = @note.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @note.destroy
      redirect_to client_notes_path, notice: t('notices.destroyed', default: 'Client note was successfully deleted.')
    else
      redirect_to edit_client_note_path(@note), alert: @note.errors.full_messages.to_sentence
    end
  end

  private

  def set_note
    @note = ClientNote.find(params[:id])
  end

  # Strong parameters for ClientNote
  def note_params
    params.require(:client_note).permit(:date, :client_id, :code, :closed, :deposit, :devolution_date)
  end

  def load_clients
    @clients = Client.order(:name)
  end
end
