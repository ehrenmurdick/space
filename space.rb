require 'chingu'
require './src/obj/player'
require './src/obj/laser'
require './src/obj/planet'
require './src/obj/bg'
require './src/obj/asteroid'
require './src/states/space'
require './src/states/warp'
require './src/lib/angle'



# We use Chingu::Window instead of Gosu::Window
#
class Game < Chingu::Window
  def initialize()
    super(1024,768,false)    
  end
  
  def setup
    switch_game_state(Space.new("sol"))
  end    
end

Game.new.show   # Start the Game update/draw loop!
