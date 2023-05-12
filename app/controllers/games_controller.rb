class GamesController < ApplicationController
  before_action :set_game

  def index
    @games = Game.all
  end

  # sets gamedb and game in set_game filter
  def show
    @game.current_player_last_left?
  end

  def new
    @game = Poker::Game.deal!
    redirect_to game_path(@game.db_id)
  end

  def reset
    Game.destroy_all
    new
  end

  def check_call
  end

  def fold
    @game.player_action(:fold)
#    update_gamedb
    redirect_to game_path(@game.db_id)
  end

  def raise_pot
    @game.player_action(:raise, amount: 10)
    redirect_to game_path(@game.db_id)
  end

  def set_game
    return unless params[:id]
    @gamedb = Game.find_by_id(params[:id])
    @game = @gamedb.data
  end

  def update_gamedb
    @gamedb.data = @game
    @gamedb.save
    @game = @gamedb.data
  end
end
