# Ranks poker hands
class Poker::HandRank
  class << self
    # returns [rank, high-rank, hand-type]
    def rank_hand(hand)
      ranks = hand.map { |card| rank_to_i(card[0]) }
      suits = hand.map { |card| card[1] }

      # Check for a straight flush
      if suits.uniq.length == 1 && (ranks.max - ranks.min) == 4
        return 9, ranks.max, 'straight flush'
      end

      # Check for a four-of-a-kind
      ranks.each do |rank|
        if ranks.count(rank) == 4
          return 8, rank, 'four of a kind'
        end
      end

      # Check for a full house
      unique_ranks = ranks.uniq
      if unique_ranks.length == 2 && ranks.count(unique_ranks[0]) == 3
        return 7, unique_ranks[0], 'full house'
      elsif unique_ranks.length == 2 && ranks.count(unique_ranks[1]) == 3
        return 7, unique_ranks[1], 'full house'
      end

      # Check for a flush
      if suits.uniq.length == 1
        return 6, ranks.max, 'flush'
      end

      # Check for a straight
      if ranks.uniq.length == 5 && (ranks.max - ranks.min) == 4
        return 5, ranks.max, 'straight'
      end

      # Check for a three-of-a-kind
      ranks.each do |rank|
        if ranks.count(rank) == 3
          return 4, rank, 'three of a kind'
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
        return 3, pairs.max, 'two pair'
      end

      # Check for a pair
      ranks.each do |rank|
        if ranks.count(rank) == 2
          return 2, rank, 'pair'
        end
      end

      # If no hand rank is found, return high card
      return 1, ranks.max, 'high card'
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
        rank, value = rank_hand(hand)

        # If the current hand is better than the best hand found so far,
        # update the best hand and its rank
        if rank > best_rank
          best_hand = hand
          best_rank = rank
        elsif rank == best_rank && value > rank_hand(best_hand)[1]
          best_hand = hand
        end
      end

      # Return the best hand as an array of 5 cards
      return best_hand
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
