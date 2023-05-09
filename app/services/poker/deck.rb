class Poker::Deck
  attr_accessor :cards

  def initialize(shuffle_deck: true)
    @cards = []
    Poker::SUITS.keys.each do |s|
      Poker::RANKS.each do |r|
        cards << Poker::Card.new(r, s)
      end
    end
    shuffle if shuffle_deck
    @drawn = []
  end

  def shuffle
    cards.shuffle!
  end

  def hand
    Poker::Hand.new(draw, draw)
  end

  def draw
    return nil if @cards.empty?
    c = @cards.pop
    @drawn << c
    c
  end

  def to_s
    cards.map(&:to_s).join(' ')
  end
end
