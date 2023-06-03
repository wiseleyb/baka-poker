# Manages betting amounts
module Poker::GameActions
  # gets actions, calcs bet options for the current player
  # min-raise, 2-6-big-blind-bet, 1/2 pot, pot, all-in
  # This takes into consideration the stage of the game (pre-flop, flop, etc)
  # returns hash of { name: amount }
  # { "min raise": 10, "2x": 20, etc. }
  def cp_actions
    h = {}
    h['fold'] = { fold: 0 }
    h['check'] = { check: cp_can_check? ? 0 : -1 }
    h['call'] = { call: cp_can_call? ? cp_call_amt : -1 }

    bets = {}
    if stage == 'Pre Flop'
      if cp_can_bet?
        (2..6).each do |mult|
          bets["bet #{mult}x BB bet".to_sym] = { bet: current_bet * mult }
        end
      else
        (2..6).each do |mult|
          bets["raise #{mult}x BB bet".to_sym] = { raise: current_bet * mult }
        end
      end
    else
      if cp_can_bet?
        (1..3).each do |mult|
          k = "pot bet "
          k = "#{k} x#{mult}" if mult > 1
          bets[k.to_sym] = { bet: pot * mult }
        end
      else
        (1..3).each do |mult|
          k = "raise pot "
          k = "#{k} x#{mult}" if mult > 1
          bets[k.to_sym] = { raise: pot * mult }
        end
      end
    end
    bets['all in'] = { all_in: current_player.stack }
    bets.each do |k, v|
      h[k] = v
    end
    h
  end
end
