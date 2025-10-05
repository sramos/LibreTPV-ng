class ClientNoteController < ApplicationController
  def index
    @notes = ClientNote.where(closed: false)
  end
end
