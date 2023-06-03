# Manages steps: post blinds, pre-flop, flop, etc
module Poker::GameSteps
  # If betting round is over this moves to the next "stage" (turn/river/etc)
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

    # Calculate each player's best hand using their hole cards and the
    # community cards
    players_hash = {}
    player_scores = {}
    players.each do |p|
      phash[p.slug] = p
      player_scores[p.slug] = p.hand_rank(community_cards)
    end

    # Determine the winning hand(s)
    winning_score = player_scores.values.max
    winning_players =
      player_scores.select {|slug, score| score = winning_score }.keys

    # Divide the pot among the winning player(s)
    pot_size = pot
    side_pots = []
    current_pot = pot_size

    while winning_players.any?
      # Determine the set of players who are all-in
      all_in_players = players_hash.select {|slug, player| current_pot >  phash}.keys

      # Determine the minimum bet that all all-in players can match
      min_all_in_bet = all_in_players.map {|player| current_pot - players[player].length }.min

      # Determine the set of players who have contributed to this pot
      contributing_players = players.select {|player, hole_cards| hole_cards.length >= min_all_in_bet }.keys

      # Calculate the size of this pot and remove it from the main pot
      pot_size = contributing_players.length * min_all_in_bet
      current_pot -= pot_size

      # Calculate the winning hand(s) for this pot
      pot_hands = player_hands.select {|player, hand| contributing_players.include?(player) }
      pot_winning_hand = pot_hands.values.max
      pot_winning_players = pot_hands.select {|player, hand| hand == pot_winning_hand }.keys

      # Divide this pot among the winning player(s) and remove them from the list of winners
      if pot_winning_players.length == 1
        # Single winner, award entire pot
        winning_player = pot_winning_players.first
        side_pots << {winning_player => pot_size}
      else
        # Split pot among winners
        winnings_per_player = pot_size / pot_winning_players.length
        pot_winning_players.each do |player|
          side_pots << {player => winnings_per_player}
        end
      end
      winning_players -= pot_winning_players
    end

    # Print the results for each side pot
    side_pots.each_with_index do |pot, i|
      puts "Side pot #{i+1}:"
      pot.each do |player, winnings|
        puts "#{player} wins #{winnings} chips with #{Hand.new(player_hands[player]).name}."
      end
    end

  end
end
