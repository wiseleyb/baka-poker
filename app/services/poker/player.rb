class Poker::Player
  attr_accessor :name, :hand, :stack

  # name: player name
  # hand: Poker::Hand
  def initialize(name, hand: nil)
    @name = name
    @hand = hand
    @stack = 1_000
  end

  def image_name
    img = name.downcase
              .squeeze(' ')
              .gsub(/[^a-z0-9\ ']/i, '')
              .squeeze(' ')
              .gsub(/[^a-z0-9']/i, '_')
    "players/#{img}.jpeg"
  end

  def to_s
    "#{name}: #{hand.to_s}"
  end
end
