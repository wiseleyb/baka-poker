class Game < ApplicationRecord
  serialize :data, Poker::Game
end
