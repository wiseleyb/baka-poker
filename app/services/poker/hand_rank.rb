# Ranks poker hands
class Poker::HandRank
  class << self
    # returns Poker::Rank
    def rank_hand(hand)
      ranks = hand.map { |card| rank_to_i(card[0]) }
      suits = hand.map { |card| card[1] }

      # Check for a straight flush
      if suits.uniq.length == 1 && (ranks.max - ranks.min) == 4
        return Poker::Rank.new(9, ranks.max, 'straight flush')
      end

      # Check for a four-of-a-kind
      ranks.each do |rank|
        if ranks.count(rank) == 4
          return Poker::Rank.new(8, rank, 'four of a kind')
        end
      end

      # Check for a full house
      unique_ranks = ranks.uniq
      if unique_ranks.length == 2 && ranks.count(unique_ranks[0]) == 3
        return Poker::Rank.new(7, unique_ranks[0], 'full house')
      elsif unique_ranks.length == 2 && ranks.count(unique_ranks[1]) == 3
        return Poker::Rank.new(7, unique_ranks[1], 'full house')
      end

      # Check for a flush
      if suits.uniq.length == 1
        return Poker::Rank.new(6, ranks.max, 'flush')
      end

      # Check for a straight
      if ranks.uniq.length == 5 && (ranks.max - ranks.min) == 4
        return Poker::rank.new(5, ranks.max, 'straight')
      end

      # Check for a three-of-a-kind
      ranks.each do |rank|
        if ranks.count(rank) == 3
          return Poker::Rank.new(4, rank, 'three of a kind')
        end
      end

      # Check for two pairs
      pairs = []
      ranks.each do |rank|
        if ranks.count(rank) == 2 && !pairs.include?(rank)
          pairs << rank
        end
      end
      if pairs.length == 2
        return Poker::Rank.new(3, pairs.max, 'two pair')
      end

      # Check for a pair
      ranks.each do |rank|
        if ranks.count(rank) == 2
          return Poker::Rank.new(2, rank, 'pair')
        end
      end

      # If no hand rank is found, return high card
      return Poker::Rank.new(1, ranks.max, 'high card')
    end

    # given 5+ cards returns best possible hand
    def best_poker_hand(cards)
      # Generate all possible combinations of 5 cards from the 7-card set
      combinations = cards.combination(5).to_a

      # Initialize variables to hold the best hand and its rank
      best_hand = nil
      best_rank = 0

      # Iterate over each combination of 5 cards and find its rank
      combinations.each do |hand|
        rank = rank_hand(hand)

        # If the current hand is better than the best hand found so far,
        # update the best hand and its rank
        if rank.score > best_rank
          best_hand = hand
          best_rank = rank.score
        elsif rank.score == best_rank && rank.score > rank_hand(best_hand).score
          best_hand = hand
        end
      end

      # Return the best hand as an array of 5 cards
      return best_hand
    end

    # Ranks players by hand
    # game: Poker::Game
    def rank_players(game)
      game.players.select {|p| !p.folded}.sort_by do |p|
        p.hand_rank(game.community_cards).score
      end.reverse
    end

    def win_pcts(game)
      # Generate a deck of cards and remove the cards that are already on the
      # board
#      deck = RubyPoker::Deck.new
#      board_cards = board.map { |card| RubyPoker::Card.new(card) }
#      deck.remove_cards(board_cards)

      # Initialize a hash to hold the win percentages for each player
      win_percentages = {}

      # Iterate over each player's hand and calculate its win percentage
      players.each do |player|
        # Convert the player's hand and the board to RubyPoker Card objects
        hand_cards = player[:cards].map { |card| RubyPoker::Card.new(card) }

        # Generate all possible combinations of 5 cards from the player's hand
        # and the board
        combinations = deck.combination(5 - board.length)

        # Initialize variables to hold the number of wins and the total number
        # of simulations
        wins = 0
        total = 0

        # Iterate over each possible combination of 5 cards and compare it to
        # the player's hand
        combinations.each do |community_cards|
          # Combine the player's hand and the community cards to form a 7-card hand
          cards = hand_cards + community_cards

          # Calculate the rank of the player's hand
          player_rank = RubyPoker::Hand.new(cards).rank

          # Iterate over each other player's hand and compare it to the
          # player's hand
          players.each do |other_player|
            if other_player != player
              # Convert the other player's hand and the board to RubyPoker Card
              # objects
              other_hand_cards = other_player[:cards].map { |card| RubyPoker::Card.new(card) }
              other_cards = other_hand_cards + community_cards

              # Calculate the rank of the other player's hand
              other_rank = RubyPoker::Hand.new(other_cards).rank

              # If the player's hand is better than the other player's hand,
              # increment the win count
              if player_rank > other_rank
                wins += 1
              end
            end
          end

          # Increment the total simulation count
          total += 1
        end

        # Calculate the win percentage for the player's hand and add it to the
        # hash
        win_percentages[player[:name]] = (wins.to_f / total * 100).round(2)
      end

      return win_percentages
    end

    def rank_to_i(rank)
      case rank
      when 'T' then 10
      when 'J' then 11
      when 'Q' then 12
      when 'K' then 13
      when 'A' then 14
      else
        rank.to_i
      end
    end
  end
end
