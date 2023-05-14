# Manages steps: post blinds, pre-flop, flop, etc
module Poker::GameSteps
  def move_to_next_stage?
    #if current_bet == 0 || (players.length - folded_players.length) == 1 || (player == last_to_bet && action == 'c')
    if (current_bet == 0 || current_player.current_bet == current_bet) &&
       player_action_cnt == player_total_action_cnt
      step_next_stage
      return true
    end
    false
  end

  def step_next_stage
    case stage
    when 'Post Blinds'
      step_post_blinds
    when 'Pre Flop'
      step_flop
    when 'Flop'
      step_turn
    when 'Turn'
      step_river
    when 'River'
      step_showdown
    when 'Showdown'
      step_end_hand
    end
    step_reset_betting_round
    save!
  end

  def step_reset_betting_round
    self.player_action_cnt = 0
    self.player_total_action_cnt = active_players.size
  end

  def step_post_blinds
    self.pot += small_blind_player.bet!(small_blind)
    small_blind_player.last_action = "posts small blind $#{small_blind}"

    self.pot += big_blind_player.bet!(big_blind)
    big_blind_player.last_action = "posts big blind $#{big_blind}"

    self.current_bet = big_blind
    log('*** Blinds ***')
    log("Seat-#{small_blind_player.seat}: posts small blind $#{small_blind}")
    log("Seat-#{big_blind_player.seat}: posts big blind $#{big_blind}")
    log('')
  end

  def step_flop
    self.stage = 'Flop'
    self.community_cards ||= []
    3.times do
      self.community_cards << deck.draw
    end
    log('')
    log('*** Flop ***')
  end

  def step_turn
    self.stage = 'Turn'
    self.community_cards ||= []
    self.community_cards << deck.draw
    log('')
    log('*** Turn ***')
  end

  def step_river
    self.stage = 'River'
    self.community_cards ||= []
    self.community_cards << deck.draw
    log('')
    log('*** River ***')
  end

  def step_showdown
    self.stage = 'Showdown'
    log('')
    log('*** River ***')
  end

  def step_end_hand
    self.stage = 'Over'

  end
end
