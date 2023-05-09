module GameHelper
  def small_card(card)
    image_tag(card.image_name, width: 70, border: 1)
  end

  def large_card(card)
    image_tag(card.image_name, width: 100, border: 1)
  end

  def player(player_idx)
    render partial: 'player', locals: { player_idx: player_idx }
  end

  def game_table
    render partial: 'table'
  end
end
