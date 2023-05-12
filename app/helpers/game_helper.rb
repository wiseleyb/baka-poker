module GameHelper
  CARD_TINY_WIDTH = 30
  CARD_SMALL_WIDTH = 70
  CARD_LARGE_WIDTH = 100

  def player(player_idx)
    render partial: 'player', locals: { player_idx: player_idx }
  end

  def player_deets(player, titles = nil)
    render partial: 'player_deets',
           locals: { player: player, titles: titles }
  end

  def player_image(player)
    image_tag(player.image_name, width: 40, style: 'border-radius: 50%')
  end

  def player_best_hand(player)
    show_txt_cards(player.best_hand(@game.community_cards))
  end

  def player_hand_rank(player)
    res = player.hand_rank(@game.community_cards)
    "#{res.last}: (#{res.first}, #{res.second})"
  end

  def game_table
    render partial: 'table'
  end

  def game_stats
    render partial: 'stats'
  end

  def small_back_card
    image_tag('cards/back.png', width: CARD_SMALL_WIDTH, border: 1)
  end

  def small_card(card)
    image_tag(card.image_name, width: CARD_SMALL_WIDTH, border: 1)
  end

  def large_card(card)
    image_tag(card.image_name, width: CARD_LARGE_WIDTH, border: 1)
  end

  def show_tiny_cards(cards)
    show_cards(cards, width: CARD_TINY_WIDTH)
  end

  def show_small_cards(cards)
    show_cards(cards, width: CARD_SMALL_WIDTH)
  end

  def show_large_cards(cards)
    show_cards(cards, width: CARD_LARGE_WIDTH)
  end

  def show_cards(cards, width:)
    cards.map {|c| image_tag(c.image_name, width: width)}.join.html_safe
  end

  def show_txt_cards(cards)
    res = []
    cards.each do |c|
      rank = c.rank
      suit = c.suit
      res << rank
      clr =
        case suit.to_sym
        when :h, :d
          'red'
        else
          'black'
        end
      res << %(<span style="color:#{clr}">#{c.suit_emoji}</span>)
    end
    res.join.html_safe
  end
end
