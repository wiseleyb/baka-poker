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
end
