# Manages steps: post blinds, pre-flop, flop, etc
module Poker::GameSteps
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
    end
  end

  def step_post_blinds
    self.pot += small_blind_player.bet!(small_blind)
    self.pot += big_blind_player.bet!(big_blind)
    self.current_bet = big_blind
    log('*** Blinds ***')
    log("Seat-#{small_blind_player.seat}: posts small blind $#{small_blind}")
    log("Seat-#{big_blind_player.seat}: posts big blind $#{big_blind}")
    log('')
    save!
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
end
