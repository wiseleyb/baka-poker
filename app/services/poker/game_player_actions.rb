# Player actions - included in Poker::Game
module Poker::GamePlayerActions
  # player checks/bets/folds/etc
  def player_action(action, amount: nil)
    amount = amount.to_i
    case action.to_sym
    when :check
      action_check
    when :fold
      action_fold
    when :bet
      action_bet(amount)
    when :call
      action_call
    when :raise
      action_raise(amount)
    else
      raise "Poker::GameActions: Unknown action:#{action}"
    end
    self.current_player_idx = player_idx(current_player_idx + 1)
    if current_player_idx == (big_blind_idx + 1)
      step_next_stage
    end
    save!
  end

  def action_check
    action_log("Seat-##{current_player.seat}: checks")
  end

  def action_fold
    current_player.folded = true
    deck.discarded << current_player.hole_card1 if current_player.hole_card1
    deck.discarded << current_player.hole_card2 if current_player.hole_card2
    #self.players = players.select {|p| !p.folded}
    action_log("Seat-##{current_player.seat}: folds")
  end

  def action_bet(amount)
    current_player.stack -= amount
    self.pot += amount
    action_log("Seat-##{current_player.seat}: bets $#{amount} to $#{pot}")
  end

  def action_call
    # TODO
    action_log("Seat-##{current_player.seat}: calls")
  end

  def action_raise(amount)
    current_player.stack -= amount
    self.pot += amount
    action_log("Seat-##{current_player.seat}: raises $#{amount} to $#{pot}")
  end

  def action_log(logmsg)
    self.last_player_action = logmsg
    log(logmsg)
  end
end
