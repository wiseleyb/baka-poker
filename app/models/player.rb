class Player < ApplicationRecord
  def self.reset!
    Poker::PLAYER_NAMES.each_with_index do |name, idx|
      p = Player.where(name: name).first_or_initialize
      p.slug = name.slugify
      p.save!
      pob = Poker::Player.new(p.id, name)
      p.image_name = pob.image_name
      p.save!
    end
  end
end
