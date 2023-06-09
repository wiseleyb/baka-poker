class Poker::Player
  attr_accessor :current_bet,
                :db_id,
                :folded,
                :hole_card1,
                :hole_card2,
                :last_action,
                :name,
                :slug,
                :seat,
                :stack

  # name: player name
  # hole_cards: Poker::HoleCards
  def initialize(db_id,
                 name,
                 seat = nil,
                 hole_card1: nil,
                 hole_card2: nil,
                 stack: 500 + rand(500))
    @current_bet = 0
    @db_id = db_id
    @folded = false
    @hole_card1 = hole_card1
    @hole_card2 = hole_card2
    @name = name
    @seat = seat
    @slug = name.slugify
    @stack = stack
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

  def all_in?
    stack.to_i <= 0
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
