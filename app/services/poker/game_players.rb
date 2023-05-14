# Manages player logic
module Poker::GamePlayers
  def current_player
    players[current_player_idx]
  end

  def folded_players
    players.select(&:folded)
  end

  def active_players
    players.select {|p| !p.folded}
  end

  def next_player
    cps = [
      players[(current_player_idx + 1)..-1],
      players[0..current_player_idx]
    ].flatten
    cp = cps.select {|p| !p.folded && !p.all_in?}.first
    self.current_player_idx = players.index(cp)
    players[current_player_idx]
    self.player_action_cnt ||= 0
    self.player_action_cnt += 1
  end

  def small_blind_idx
    player_idx(dealer_idx + 1)
  end

  def small_blind_player
    players[small_blind_idx]
  end

  def big_blind_idx
    player_idx(dealer_idx + 2)
  end

  def big_blind_player
    players[big_blind_idx]
  end

  def player_idx(idx)
    idx >= players.size ? idx - players.size : idx
  end

  def last_player_to_bet
    players[last_player_idx_to_bet] if last_player_idx_to_bet
  end

  def cp_can_check?
    current_player.current_bet == current_bet
  end

  def cp_can_bet?
    current_bet == big_blind
  end

  def cp_can_call?
    cp_call_amt > 0
  end

  def cp_call_amt
    current_bet - current_player.current_bet
  end

  # returns list of ranked players
  def rank_players
    Poker::HandRank.rank_players(self)
  end
end
