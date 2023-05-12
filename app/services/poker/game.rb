class Poker::Game
  include PokerGameSerializable

  attr_accessor :db_id,
                :community_cards,
                :deck,
                :players,
                :pot,
                :dealer_idx,
                :current_player_idx,
                :current_bet,
                :big_blind,
                :small_blind,
                :hand_over

  def initialize(json)
    data = JSON.parse(json)
    return unless data.present?
    data.deep_symbolize_keys!

    # cards
    @community_cards = []
    data[:community_cards].each do |cc|
      @community_cards << Poker::Card.new(cc[:rank], cc[:suit])
    end

    # deck
    @deck = Poker::Deck.new
    @deck.cards = []
    data[:deck][:cards].each do |cc|
      @deck.cards << Poker::Card.new(cc[:rank], cc[:suit])
    end
    @deck.drawn = []
    data[:deck][:drawn].each do |cc|
      @deck.drawn << Poker::Card.new(cc[:rank], cc[:suit])
    end
    @deck.discarded = []
    data[:deck][:discarded].each do |cc|
      @deck.discarded << Poker::Card.new(cc[:rank], cc[:suit])
    end

    # players
    @players = []
    data[:players].each do |p|
      player = Poker::Player.new(p[:db_id], p[:name])
      if (cc = p[:hole_card1]).present?
        player.hole_card1 = Poker::Card.new(cc[:rank], cc[:suit])
      end
      if (cc = p[:hole_card2]).present?
        player.hole_card2 = Poker::Card.new(cc[:rank], cc[:suit])
      end
      player.stack = p[:stack]
      player.current_bet = p[:current_bet]
      player.folded = p[:folded]
      @players << player
    end

    @big_blind = data[:big_blind].to_i
    @small_blind = data[:small_blind].to_i
    @pot = data[:pot]
    @dealer_idx = data[:dealer_idx]
    @current_player_idx = data[:current_player_idx]
    @current_bet = data[:current_bet]
    @db_id = data[:db_id]
    @hand_over = data[:hand_over]
  end

  def self.deal!(player_cnt = 6)
    pg = Poker::Game.new({}.to_json)
    pg.deck = Poker::Deck.new
    pg.players = []
    Player.order('random()').limit(player_cnt).each do |p|
      pg.players << Poker::Player.new(p.id,
                                      p.name,
                                      hole_card1: pg.deck.draw,
                                      hole_card2: pg.deck.draw)
    end
    pg.dealer_idx = 0
    pg.current_player_idx = pg.dealer_idx + 3
    pg.community_cards = 5.times.map { pg.deck.draw }

    pg.pot = 0
    pg.small_blind = 3
    pg.pot += pg.small_blind_player.bet!(pg.small_blind)
    pg.big_blind = 5
    pg.pot += pg.big_blind_player.bet!(pg.big_blind)
    pg.current_bet = pg.big_blind
    pg.hand_over = false
    g = Game.create
    pg.db_id = g.id
    g.data = pg
    g.save
    pg
  end

  def small_blind_idx
    player_idx(dealer_idx + 1)
  end
  def small_blind_player
    players[small_blind_idx]
  end

  def big_blind_idx
    player_idx(dealer_idx + 2)
  end
  def big_blind_player
    players[big_blind_idx]
  end

  def current_player
    players[current_player_idx]
  end

  def player_idx(idx)
    idx >= @players.size ? idx - @players.size : idx
  end

  def fold!
    current_player.folded = true
    deck.discarded << current_player.hole_card1 if current_player.hole_card1
    deck.discarded << current_player.hole_card2 if current_player.hole_card2
    # current_player.hole_card1 = nil
    # current_player.hole_card2 = nil
    self.current_player_idx = player_idx(current_player_idx + 1)
  end

  def current_player_last_left?
    return false if current_player.folded
    if players.select {|p| p.folded == true}.size == players.size - 1
      current_player.stack += pot
      self.pot = 0
      self.hand_over = true
      return true
    end
    false
  end

  def to_s
    res = []
    res << players.map(&:to_s)
    res << ''
    res << "#{deck.cards.size}: #{deck.to_s}"
    res.flatten.join("\n")
  end

  def list_to_s
    res = []
    res << "#{db_id}: "
    res << community_cards.map(&:to_s).join('&nbsp;')
    res << ApplicationController.helpers.number_to_currency(pot)
    res.join('&nbsp;').html_safe
  end
end
