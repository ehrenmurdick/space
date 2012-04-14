class Land < Chingu::GameState
  trait :viewport
  attr_accessor :player, :draw_list
  def initialize(planet)
    super()
    @bg = Bg.create
    @bg.scale = 3
    @bg.y = 1000
    @bg.y = 1000
    @bg.image = planet.surface
    self.viewport.game_area = [0, 0, 2000, 2000] 
    @player = Lander.create
    @player.x, @player.y = 1000, 1000
  end

  def setup
    super
    $state = self
  end

  def button_down(id)
    @player.turn_left       if id == Gosu::Button::KbLeft
    @player.turn_right      if id == Gosu::Button::KbRight
    @player.accelerate      if id == Gosu::Button::KbUp
    @player.reverse         if id == Gosu::Button::KbDown
    @player.boost           if id == Gosu::Button::KbSpace
    takeoff!                if id == Gosu::Button::KbL

    exit if id == Gosu::Button::KbQ
  end

  def button_up(id)
    @player.halt_turn	  	if id == Gosu::Button::KbLeft
    @player.halt_turn   	if id == Gosu::Button::KbRight
    @player.drift         if id == Gosu::Button::KbUp
    @player.halt_reverse  if id == Gosu::Button::KbDown
    @player.halt_seek     if id == Gosu::Button::KbA
    @player.halt_fire     if id == Gosu::Button::KbSpace
    @player.halt_boost    if id == Gosu::Button::KbSpace
  end

  def takeoff!
    $window.pop_game_state
  end

  def update
    super
    viewport.center_around(@player)
  end
end
