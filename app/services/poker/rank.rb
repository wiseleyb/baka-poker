class Poker::Rank
  attr_accessor :score, :rank, :max_card, :name

  def initialize(rank, max_card, name)
    @score = rank.to_f + max_card.to_f / 100
    @rank = rank
    @max_card = max_card
    @name = name
  end
end
