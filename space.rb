require 'chingu'


module Angle
  class << self
    def dtor(deg)
      deg * Math::PI / 180 
    end

    def rtod(rad)
      rad * 180 / Math::PI
    end
  end
end

# We use Chingu::Window instead of Gosu::Window
#
class Game < Chingu::Window
  def initialize()
    super(800,500,false)    
    @song = Gosu::Song.new(self, "assets/music/calm.wav")
    @song.play(true)
  end
  
  def setup
    switch_game_state(Space.new)
  end    
end

class Space < Chingu::GameState
  trait :viewport
  def initialize
    super       # This is always needed if you override Window#initialize
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #

    self.viewport.game_area = [0, 0, 1024*2, 768*2] 


    @bg = Bg.create
    @bg.factor = 2
    @bg.x = 1024
    @bg.y = 768
    @player = Player.create
    @player.x = 300
    @player.y = 300
    @player.angle = 0

  end    

  def button_down(id)
    @player.turn_left		 if id == Gosu::Button::KbLeft
    @player.turn_right	 if id == Gosu::Button::KbRight
    @player.accelerate   if id == Gosu::Button::KbUp
    @player.reverse      if id == Gosu::Button::KbDown
    @player.start_firing if id == Gosu::Button::KbSpace
  end

  def button_up(id)
    @player.halt_turn	  	if id == Gosu::Button::KbLeft
    @player.halt_turn   	if id == Gosu::Button::KbRight
    @player.drift         if id == Gosu::Button::KbUp
    @player.halt_reverse  if id == Gosu::Button::KbDown
    @player.halt_fire     if id == Gosu::Button::KbSpace
  end

  def update
    super
    self.viewport.center_around(@player)
  end
end

#
# If we create classes from Chingu::GameObject we get stuff for free.
# The accessors image,x,y,zorder,angle,factor_x,factor_y,center_x,center_y,mode,alpha.
# We also get a default #draw which draws the image to screen with the parameters listed above.
# You might recognize those from #draw_rot - http://www.libgosu.org/rdoc/classes/Gosu/Image.html#M000023
# And in it's core, that's what Chingu::GameObject is, an encapsulation of draw_rot with some extras.
# For example, we get automatic calls to draw/update with Chingu::GameObject, which usually is what you want. 
# You could stop this by doing: @player = Player.new(:draw => false, :update => false)
#
class Player < Chingu::GameObject
  traits :sprite, :timer
  attr_accessor :angular


  def initialize
    @angular = 0
    @velocity_x, @velocity_y = 0, 0
    @rocket = Gosu::Sample.new("sounds/rocket.wav")
    @laser = Gosu::Sample.new("sounds/laser.wav")
    super(:image => "assets/player.png")
  end

  def start_firing
    fire
    every(150, :name => :fire) do
      fire
    end
  end

  def fire
    @laser.play
    shot = Laser.create(angle)
    shot.x = x
    shot.y = y
    shot.factor = 0.1
    shot.angle = angle
  end

  def halt_fire
    stop_timer :fire
  end

  def turn_left
    @angular = -1
    @image = Gosu::Image["assets/player-l.png"]
  end

  def turn_right
    @angular = 1
    @image = Gosu::Image["assets/player-r.png"]
  end    

  def halt_turn
    @angular = 0
    @image = Gosu::Image["assets/player.png"]
  end

  def accelerate
    @thruster = true
    @r = @rocket.play
  end

  def drift
    @thruster = false
    @r.stop
  end

  def reverse
    @reverse = true
  end

  def halt_reverse
    @reverse = false
  end

  def image
    str = ""
    str += "-t1" if @thruster
    str += "-l" if @angular < 0
    str += "-r" if @angular > 0
    Gosu::Image["assets/player#{str}.png"]
  end

  def angle_diff(a, b)
    ((((a - b) % 360) + 540) % 360) - 180
  end

  def update
    @angle += (@angular * 5)
    @angle %= 360
    @x += @velocity_x
    @y += @velocity_y
    @image = image

    if @thruster
      @velocity_x += Math.sin(Angle.dtor(@angle)) / 10.0
      @velocity_y -= Math.cos(Angle.dtor(@angle)) / 10.0
    end

    if @reverse
      rad = Math::atan2(-@velocity_x, @velocity_y)
      goal_angle = Angle.rtod(rad)
      goal_angle += 360
      goal_angle %= 360

      if angle_diff(@angle, goal_angle) < 1
        @angle += 5
      else
        @angle -= 5
      end
    end
  end
end

class Laser < Chingu::GameObject
  traits :sprite
  def initialize(angle)
    self.factor = 0.3
    self.factor_y = 0.5
    angle -= 90
    angle %= 360
    @velocity_x = Math.sin(Angle.dtor(angle)) * 10.0
    @velocity_y = Math.cos(Angle.dtor(angle)) * 10.0
    super(:image => "assets/laser.png", :zorder => 50)
  end

  def update
    @x += @velocity_y
    @y += @velocity_x
  end
end

class Planet < Chingu::GameObject
  traits :sprite
  def initialize
    self.scale = 10
    super(:image => "assets/planet.png")
  end
end

class Bg < Chingu::GameObject
  def initialize
    super(:image => "assets/starfield.jpg", :zorder => 0)
  end
end

Game.new.show   # Start the Game update/draw loop!
