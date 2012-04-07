require 'chingu'


module Angle
  class << self
    def dtor(deg)
      deg * Math::PI / 180 
    end

    def mag(vx, vy)
      Math.sqrt((vx.abs*vx.abs) + (vy.abs*vy.abs))
    end

    def rtod(rad)
      rad * 180 / Math::PI
    end

    def vtoa(vx, vy)
      rad = Math::atan2(-vx, vy)
      (rtod(rad) + 180) % 360
    end

    def reverse_v(vx, vy)
      (vtoa(vx, vy) + 180) % 360
    end
  end
end

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

class Space < Chingu::GameState
  trait :viewport
  attr_accessor :player
  attr_reader :danger, :song
  def initialize
    super
    $danger = Gosu::Song["assets/music/danger.wav"]
    $song = 0
    $songs = ["calm.wav", "planet2.wav"].map do |s|
      Gosu::Song["assets/music/#{s}"]
    end
    srand
    $songs[rand($songs.length)].play(true)
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #

    self.viewport.game_area = [0, 0, 10_000, 10_000] 

    @parallax = Chingu::Parallax.create(:x => 150, :y => 150)
    @parallax << { :image => "assets/bg.png", :repeat_x => true, :repeat_y => true, :damping => 10, :x => 150, :y => 150}

    @planet = Planet.create
    @planet.x = 5000
    @planet.y = 5000



    @player = Player.create
    @player.target = @planet
    @player.x = 4500
    @player.y = 4500
    @player.angle = 0
    @player.zorder = 200


    @parallax.x = @player.x
    @parallax.y = @player.y

  end    

  def button_down(id)
    @player.turn_left		 if id == Gosu::Button::KbLeft
    @player.turn_right	 if id == Gosu::Button::KbRight
    @player.accelerate   if id == Gosu::Button::KbUp
    @player.reverse      if id == Gosu::Button::KbDown
    @player.start_firing if id == Gosu::Button::KbSpace
    @player.warp         if id == Gosu::Button::KbW
    @player.seek_target  if id == Gosu::Button::KbA

    exit if id == Gosu::Button::KbQ
  end

  def button_up(id)
    @player.halt_turn	  	if id == Gosu::Button::KbLeft
    @player.halt_turn   	if id == Gosu::Button::KbRight
    @player.drift         if id == Gosu::Button::KbUp
    @player.halt_reverse  if id == Gosu::Button::KbDown
    @player.halt_seek     if id == Gosu::Button::KbA
    @player.halt_fire     if id == Gosu::Button::KbSpace
  end

  def update
    super
    viewport.center_around(@player)
    @parallax.x = @player.x
    @parallax.y = @player.y
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
  attr_accessor :angular, :locked, :velocity_x, :velocity_y, :slowdown, :target

  def initialize
    @angular = 0
    @velocity_x, @velocity_y = 0, 0
    @rocket = Gosu::Sample.new("sounds/rocket.wav")
    @laser = Gosu::Sample.new("sounds/laser.wav")
    @speed_factor = 1
    super(:image => "assets/player.png")
  end

  def lock!
    self.locked = true
  end

  def unlock!
    self.locked = false
  end

  def scale_speed(amt)
    @velocity_x = @velocity_x * amt
    @velocity_y = @velocity_y * amt
  end

  def warp
    Gosu::Sound["charge.wav"].play
    lock!
    after(2300) do
      Gosu::Sound["jump.wav"].play
      @speed_factor = 50
      @thruster = true
    end
    after(5000) do
      scale_speed(0.1)
      new_state = Space.new
      new_state.player.x = 4000
      new_state.player.y = 5000
      new_state.player.velocity_x = @velocity_x
      new_state.player.velocity_y = @velocity_y
      new_state.player.angle = angle
      new_state.player.slowdown!
      $window.switch_game_state(new_state)
    end
  end

  def start_firing
    unless locked
      fire
      every(150, :name => :fire) do
        fire
      end
    end
  end

  def vx
    @velocity_x
  end

  def vy
    @velocity_y
  end

  def fire
    return if locked
    @laser.play
    shot = Laser.create(angle, vx, vy)
    shot.x = x
    shot.y = y
    shot.factor = 0.1
    shot.angle = angle
  end

  def halt_fire
    stop_timer :fire
  end

  def slowdown!
    lock!
    @slowdown = true
    after(500) do
      @slowdown = false
      unlock!
    end
  end

  def turn_left
    return if locked
    @angular = -1
    @image = Gosu::Image["assets/player-l.png"]
  end

  def turn_right
    return if locked
    @angular = 1
    @image = Gosu::Image["assets/player-r.png"]
  end    

  def halt_turn
    @angular = 0
    @image = Gosu::Image["assets/player.png"]
  end

  def accelerate
    return if locked
    @thruster = true
    @r = @rocket.play
  end

  def drift
    @thruster = false
    @r.stop
  end

  def reverse
    return if locked
    @reverse = true
  end

  def seek_target
    return if locked
    @seek = true
  end

  def halt_seek
    @seek = false
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
      @velocity_x += (Math.sin(Angle.dtor(@angle)) / 10.0) * @speed_factor
      @velocity_y -= (Math.cos(Angle.dtor(@angle)) / 10.0) * @speed_factor
    end

    if Angle.mag(@velocity_x, @velocity_y) > 10 * @speed_factor
      @velocity_x = 0.9 * @velocity_x
      @velocity_y = 0.9 * @velocity_y
    end

    if @reverse
      goal_angle = Angle.reverse_v(@velocity_x, @velocity_y)
      turn_to(goal_angle)
    end

    if @seek && @target
      goal_angle = Angle.vtoa(@target.x - x, @target.y - y)
      turn_to(goal_angle)
    end
  end

  def turn_to(goal_angle)
    if angle_diff(@angle, goal_angle).abs < 5
      @angle = goal_angle
    elsif angle_diff(@angle, goal_angle) < 0
      @angle += 5
    else
      @angle -= 5
    end
  end
end

class Laser < Chingu::GameObject
  traits :sprite, :timer
  def initialize(angle, vx, vy)
    self.factor = 0.3
    angle -= 90
    angle %= 360
    @velocity_x = Math.sin(Angle.dtor(angle)) * 12.0
    @velocity_y = Math.cos(Angle.dtor(angle)) * 12.0
    super(:image => "assets/laser.png", :zorder => 150)
  end

  def setup
    after(5000) do
      destroy
    end
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
    super(:image => "assets/bg.png", :zorder => 0)
  end
end

Game.new.show   # Start the Game update/draw loop!
