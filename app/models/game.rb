# Stores game data
class Game < ApplicationRecord
  serialize :data, Poker::Game
  has_many :game_hands, dependent: :destroy
end
