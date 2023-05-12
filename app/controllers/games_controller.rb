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

  def action_check
    @game.player_action(:check)
    redirect_to game_path(@game.db_id)
  end

  def action_fold
    @game.player_action(:fold)
    redirect_to game_path(@game.db_id)
  end

  def action_bet
    @game.player_action(:bet, amount: params[:amount])
    redirect_to game_path(@game.db_id)
  end

  def action_call
    @game.player_action(:call)
    redirect_to game_path(@game.db_id)
  end

  def action_raise
    @game.player_action(:raise, amount: params[:amount])
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
