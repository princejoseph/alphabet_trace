class AlphabetController < ApplicationController
  def show
    @letter = params[:letter]
  end
end
