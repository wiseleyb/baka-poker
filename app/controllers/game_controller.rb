class GameController < ApplicationController
  def index
    @game = Poker::Game.new
  end
end
