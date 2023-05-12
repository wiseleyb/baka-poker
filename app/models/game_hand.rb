# Manages poker logs for a hand
# Based on: https://en.wikipedia.org/wiki/Hand_history
class GameHand < ApplicationRecord
  belongs_to :game

  def self.log(str, game_id, game_hand_id = nil)
    if game_hand_id
      gl = GameHand.where(game_id: game_id, id: game_hand_id).first
      gl.log ||= ''
      gl.log += str.chomp + "\n"
      gl.save
      gl
    else
      GameHand.create(game_id: game_id, log: str.chomp + "\n")
    end
  end
end
