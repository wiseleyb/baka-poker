class Poker::Game
  attr_accessor :community_cards,
                :deck,
                :players,
                :pot,
                :table,
                :dealer_idx,
                :current_player_idx

  def initialize(player_cnt = 6)
    @deck = Poker::Deck.new
    @players = []
    Poker::PLAYER_NAMES.shuffle[0..(player_cnt - 1)].each do |name|
      @players << Poker::Player.new(name, hand: @deck.hand)
    end
    @dealer_idx = 0
    @current_player_idx = @dealer_idx + 3
    @community_cards = 5.times.map { @deck.draw }
    @pot = 10_000
  end

  def small_blind_idx
    player_idx(dealer_idx + 1)
  end

  def big_blind_idx
    player_idx(dealer_idx + 2)
  end

  def player_idx(idx)
    idx > @players.size ? idx - @players.size : idx
  end

  def to_s
    res = []
    res << players.map(&:to_s)
    res << ''
    res << "#{deck.cards.size}: #{deck.to_s}"
    res.flatten.join("\n")
  end
end
