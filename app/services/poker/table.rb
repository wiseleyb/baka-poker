class Poker::Table
  attr_accessor :players

  # players: [Poker::Player]
  def initialize(players)
    @players = players
  end

  def to_s
    @players.map(&:to_s).join("\n")
  end
end
