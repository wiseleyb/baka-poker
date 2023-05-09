class Poker::Player
  attr_accessor :db_id,
                :name,
                :hole_card1,
                :hole_card2,
                :stack,
                :current_bet,
                :folded

  # name: player name
  # hole_cards: Poker::HoleCards
  def initialize(db_id, name, hole_card1: nil, hole_card2: nil)
    @db_id = db_id
    @name = name
    @hole_card1 = hole_card1
    @hole_card2 = hole_card2
    @stack = 1_000
    @current_bet = 0
    @folded = false
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

  def to_s
    "#{name}: #{hole_card1.to_s}#{hole_card2.to_s}"
  end
end
