class Poker::Player
  attr_accessor :db_id,
                :name,
                :hole_card1,
                :hole_card2,
                :stack,
                :current_bet,
                :folded,
                :seat

  # name: player name
  # hole_cards: Poker::HoleCards
  def initialize(db_id, name, seat, hole_card1: nil, hole_card2: nil)
    @db_id = db_id
    @name = name
    @hole_card1 = hole_card1
    @hole_card2 = hole_card2
    @stack = 1_000
    @current_bet = 0
    @folded = false
    @seat = seat
  end

  def hole_cards
    [hole_card1, hole_card2]
  end

  def bet!(amount)
    return 0 unless stack
    self.stack -= amount
    self.current_bet += amount
    amount
  end

  def fold!
    self.folded = true
  end

  def image_name
    img = name.downcase
              .squeeze(' ')
              .gsub(/[^a-z0-9\ ']/i, '')
              .squeeze(' ')
              .gsub(/[^a-z0-9']/i, '_')
    "players/#{img}.jpeg"
  end

  def best_hand(community_cards)
    pcards = [hole_cards, community_cards].flatten
    cards = Poker::Card.cards_to_std_array(pcards)
    Poker::Card.std_array_to_cards(Poker::HandRank.best_poker_hand(cards))
  end

  def hand_rank(community_cards)
    bh = best_hand(community_cards)
    cards = Poker::Card.cards_to_std_array(bh)
    Poker::HandRank.rank_hand(cards)
  end

  def to_s
    "#{name}: #{hole_card1.to_s}#{hole_card2.to_s}"
  end
end
