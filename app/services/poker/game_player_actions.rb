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
    when :all_in
      action_all_in
    else
      raise "Poker::GameActions: Unknown action:#{action}"
    end
    next_player
    move_to_next_stage?
    save!
  end

  def action_check
    action_log('checks')
  end

  def action_fold
    current_player.folded = true
    deck.discarded << current_player.hole_card1 if current_player.hole_card1
    deck.discarded << current_player.hole_card2 if current_player.hole_card2
    action_log('folds')
  end

  def action_bet(amount)
    action_bet_raise(amount, 'bet')
  end

  def action_call
    amt = cp_call_amt.to_i
    current_player.bet!(amt)
    self.pot += amt
    action_log("calls #{GameHelper.fmt_money(amt)} to "\
               "#{GameHelper.fmt_money(pot)}")
  end

  def action_raise(amount)
    action_bet_raise(amount, 'raises')
  end

  def action_bet_raise(amount, action_type)
    raise "Invalid #{action_type} amount." if amount <= current_bet
    current_player.bet!(amount)
    self.pot += amount
    self.current_bet += amount
    self.last_player_idx_to_bet = current_player_idx
    action_log("#{action_type}s  #{GameHelper.fmt_money(amount)} to "\
               "#{GameHelper.fmt_money(pot)}")
  end

  def action_all_in
    amount = current_player.stack
    self.current_bet = amount - current_bet if amount > current_bet
    self.pot += amount
    current_player.bet!(amount)
    action_log('all-in')
  end

  def action_log(logmsg)
    self.last_player_action = logmsg
    current_player.last_action = logmsg
    log("Seat ##{current_player.seat}: #{current_player.slug} #{logmsg}")
  end
end
