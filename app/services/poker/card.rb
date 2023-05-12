class Poker::Card
  attr_accessor :rank,
                :rank_name,
                :rank_value,
                :suit,
                :suit_emoji,
                :suit_name

  def initialize(rank, suit)
    @rank = rank
    @rank_value = Poker::RANKS.index(rank)
    @rank_name = Poker::RANK_NAMES[@rank_value]
    @suit = suit.downcase.to_sym
    @suit_emoji = Poker::SUITS[@suit]
    @suit_name = Poker::SUIT_NAMES[@suit]
  end

  def image_name
    "cards/#{rank_name}_of_#{suit_name}s.png"
  end

  def to_s
    "#{rank}#{suit_emoji}"
  end

  # returns stand poker notation like: 2h
  def to_std
    "#{rank}#{suit}"
  end

  # converts from Poker::Card -> standard poker notation like: 2h
  def self.cards_to_std_array(cards)
    cards.map(&:to_std)
  end

  # converts standard poker notiation array to Poker::Cards
  def self.std_array_to_cards(std_cards)
    std_cards.map {|c| Poker::Card.new(c[0], c[1])}
  end
end
