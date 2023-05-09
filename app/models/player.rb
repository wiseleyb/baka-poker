class Player < ApplicationRecord
  def self.reset!
    Poker::PLAYER_NAMES.each do |name|
      p = Player.where(name: name).first_or_create
      pob = Poker::Player.new(p.id, name)
      p.image_name = pob.image_name
      p.save!
    end
  end
end
