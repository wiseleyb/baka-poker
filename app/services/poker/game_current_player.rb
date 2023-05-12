# Manages current player methods - included in Poker::Game
module Poker::GameCurrentPlayer
  def current_player
    active_players[current_player_idx]
  end

  def current_player_last_left?
    return false if current_player.folded
    if players.select {|p| p.folded == true}.size == players.size - 1
      current_player.stack += pot
      self.pot = 0
      self.hand_over = true
      return true
    end
    false
  end
end
