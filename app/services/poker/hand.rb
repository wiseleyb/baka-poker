class Poker::Hand
  attr_accessor :cards

  # card1: Poker::Card
  # card2: POker::Card
  def initialize(card1, card2)
    @cards = [card1, card2]
  end

  def first; cards.first; end
  def last; cards.last; end

  def to_s
    cards.map(&:to_s).join(' ')
  end
end
