class Poker::Game
  include PokerGameSerializable
  include Poker::GamePlayers
  include Poker::GamePlayerActions
  include Poker::GameSteps
  include Poker::GameActions

  attr_accessor :big_blind,
                :community_cards,
                :current_bet,
                :current_player_idx,
                :current_players,
                :db_game_hand_id,
                :db_id,
                :dealer_idx,
                :deck,
                :hand_over,
                :last_player_action,
                :last_player_idx_to_bet,
                :player_action_cnt,
                :player_total_action_cnt,
                :players,
                :pot,
                :small_blind,
                :stage

  def initialize(json)
    data = JSON.parse(json)
    return unless data.present?
    data.deep_symbolize_keys!

    # cards
    @community_cards = []
    (data[:community_cards] || []).each do |cc|
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
    data[:players].each_with_index do |p, idx|
      player = Poker::Player.new(p[:db_id], p[:name], idx + 1)
      if (cc = p[:hole_card1]).present?
        player.hole_card1 = Poker::Card.new(cc[:rank], cc[:suit])
      end
      if (cc = p[:hole_card2]).present?
        player.hole_card2 = Poker::Card.new(cc[:rank], cc[:suit])
      end
      player.current_bet = p[:current_bet].to_i
      player.folded = p[:folded].to_bool
      player.last_action = p[:last_action]
      player.seat = p[:seat]
      player.slug = p[:slug]
      player.stack = p[:stack]
      @players << player
    end

    @big_blind = data[:big_blind].to_i
    @current_bet = data[:current_bet]
    @current_player_idx = data[:current_player_idx]
    @db_game_hand_id = data[:db_game_hand_id]
    @db_id = data[:db_id]
    @dealer_idx = data[:dealer_idx]
    @hand_over = data[:hand_over].to_bool
    @last_player_action = data[:last_player_action]
    @last_player_idx_to_bet = data[:last_player_idx_to_bet].to_i
    @player_action_cnt = data[:player_action_cnt].to_i
    @player_total_action_cnt = data[:player_total_action_cnt].to_i
    @pot = data[:pot]
    @small_blind = data[:small_blind].to_i
    @stage = data[:stage]
  end

  # Deals a new game
  def self.deal!(player_cnt = 6)
    g = Game.create
    pg = Poker::Game.new({}.to_json)
    pg.deck = Poker::Deck.new
    pg.dealer_idx = 0
    pg.current_player_idx = pg.dealer_idx + 3

    pg.pot = 0
    pg.small_blind = 3
    pg.big_blind = 5
    pg.stage = 'Pre Flop'
    pg.hand_over = false
    pg.db_id = g.id
    pg.db_game_hand_id =
      GameHand.log("*** #{Poker::BAKA} Poker ***", g.id).id
    pg.log("Date: #{Time.now}")
    pg.log("Game: ##{g.id}")
    pg.log("Hand: ##{pg.db_game_hand_id}")
    pg.log("Deck: #{pg.deck.to_std}")
    pg.log("Small Blind: $#{pg.small_blind}")
    pg.log("Big Blind: $#{pg.big_blind}")
    pg.log('')


    pg.players = []
    Player.order('random()').limit(player_cnt).each_with_index do |p, idx|
      pg.players << Poker::Player.new(p.id,
                                      p.name,
                                      idx + 1,
                                      hole_card1: pg.deck.draw,
                                      hole_card2: pg.deck.draw)
    end
    pg.log('*** Players ***')
    pg.players.each_with_index do |p, idx|
      pg.log("Seat-#{idx + 1}: id:#{p.db_id}; "\
             "name:#{p.name}; "\
             "slug:#{p.slug}; "\
             "stack:$#{p.stack}; "\
             "hole-cards:#{p.hole_cards.map(&:to_std).join(' ')}")
    end
    pg.log('')

    pg.player_action_cnt = 0
    pg.player_total_action_cnt = pg.players.size

    pg.save!
    pg.step_post_blinds

    pg.log('')
    pg.log('*** Pre Flop ***')
    pg.save!

    pg
  end

  # Prepares for new hand
  # * moves blinds
  # * resets folded players
  # * resets all in players
  # * removes players who busted
  # * resets hand-over
  # * re-deals
  def next_hand
  end

  def hand_over?
    raise 'todo'
    return false if current_player.folded
    if players.select {|p| p.folded && !p.all_in?}.size == players.size - 1
      current_player.stack += pot
      self.pot = 0
      self.hand_over = true
      return true
    end
    false
  end

  # Figures out player titles and css names - mostly for UI
  # returns [titles, css_names] both arrays
  def get_titles(player_idx)
    titles = []
    cnames = []

    if player_idx == current_player_idx
      titles << '[C]'
      cnames << 'current'
    end

    if player_idx == dealer_idx
      titles << '[D]'
      cnames << 'dealer'
    end
    if player_idx == small_blind_idx
      titles << '[S]'
      cnames << 'small-blind'
    end
    if player_idx == big_blind_idx
      titles << '[B]'
      cnames << 'big-blind'
    end

    cnames << 'folded' if players[player_idx].folded

    # cnames << 'all-in' if player.all_in?
    [titles, cnames]
  end

  def save!
    g = Game.find(db_id)
    g.data = self
    g.save
  end

  def read_log
    GameHand.find_by_id(db_game_hand_id).try(&:log)
  end

  def log(str)
    GameHand.log(str, db_id, db_game_hand_id)
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
    res << GameHelper.fmt_money(pot)
    res.join('&nbsp;').html_safe
  end
end
