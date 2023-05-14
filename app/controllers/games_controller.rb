class GamesController < ApplicationController
  before_action :set_game

  def index
    @games = Game.all
  end

  # sets gamedb and game in set_game filter
  def show
  end

  def new
    @game = Poker::Game.deal!
    redirect_to game_path(@game.db_id)
  end

  def reset
    Game.destroy_all
    new
  end

  def player_action
    @game.player_action(params[:player_action], amount: params[:amount].to_i)
    redirect_to game_path(@game.db_id)
  end

  def next_game
    @game.next_hand
  end

  def set_game
    return unless params[:id]
    @gamedb = Game.find_by_id(params[:id])
    @game = @gamedb.data
  end
end
