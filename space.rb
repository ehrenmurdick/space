require 'chingu'
require './src/obj/player'
require './src/obj/laser'
require './src/obj/planet'
require './src/obj/bg'
require './src/states/space'
require './src/lib/angle'



# We use Chingu::Window instead of Gosu::Window
#
class Game < Chingu::Window
  def initialize()
    super(800,500,false)    
  end
  
  def setup
    switch_game_state(Space.new)
  end    
end

Game.new.show   # Start the Game update/draw loop!
