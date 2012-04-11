require 'yaml'
require './src/obj/npc'
class Space < Chingu::GameState
  trait :viewport
  attr_accessor :player, :draw_list
  attr_reader :danger, :song
  def initialize(system)
    super()
    @system = YAML.load(File.read("data/systems.yml"))[system]
    @font = Gosu::Font.new($window, "verdana", 30)
    $danger = Gosu::Song["assets/music/danger.wav"]
    @song = Gosu::Song["assets/music/#{@system["music"]}"]
    $state = self
    @song.play(true)
    @map_rect = Chingu::Rect.new($window.width - 200, 0, 200, 200)
    @fuel_rect = Chingu::Rect.new($window.width - 200, 210, 200, 10)
    @fuel_level = Chingu::Rect.new(@fuel_rect)
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #

    self.viewport.game_area = [0, 0, 10_000, 10_000] 

    @planets = []
    @system["planets"].each do |name, attrs|
      p = Planet.create
      p.image = Gosu::Image["assets/planets/#{attrs["image"]}"]
      p.x = attrs["x"]
      p.y = attrs["y"]
      p.scale = attrs["scale"]
      p.name = name
      @planets << p
      next unless attrs["npcs"]
      attrs["npcs"].each do |klass, n|
        n.times do 
          npc = Npc.create
          npc.planet = p
          npc.ship = klass
          npc.x = p.x
          npc.y = p.y
          npc.zorder += 10
        end
      end
    end



    @player = Player.create
    @player.x = 4500
    @player.y = 4500
    @player.angle = 0
    @player.zorder = 200
    $player = @player

    @player.system = system

    @bg = Bg.create

    @asteroids = []
    rand(10).times do 
      as = Asteroid.create
      as.position_near(@planets.first.x, @planets.first.y)
      @asteroids << as
    end


    @player.target = @planets.first
  end    

  def button_down(id)
    map!                    if id == Gosu::Button::KbM
    @player.next_target     if id == Gosu::Button::KbTab
    @player.turn_left       if id == Gosu::Button::KbLeft
    @player.turn_right      if id == Gosu::Button::KbRight
    @player.accelerate      if id == Gosu::Button::KbUp
    @player.reverse         if id == Gosu::Button::KbDown
    @player.start_firing    if id == Gosu::Button::KbSpace
    @player.warp            if id == Gosu::Button::KbW
    @player.seek_target     if id == Gosu::Button::KbA
    @player.ship = "scout"  if id == Gosu::Button::Kb1
    @player.ship = "valk"   if id == Gosu::Button::Kb2
    @player.ship = "wraith" if id == Gosu::Button::Kb3
    $danger.play(true)      if id == Gosu::Button::KbP

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

  def map!
    map = Map.new(@system["x"], @system["y"])
    map.player = @player
    $window.push_game_state(map)
  end

  def setup
    $state = self
    if $target_system
      @player.target_system = $target_system
      if @player.system != @player.target_system
        @player.warp
      end
    end
  end

  def update
    super
    viewport.center_around(@player)
    @bg.x = ((@player.x / 640.0).floor * 640) + (@player.x * 0.2) % 640
    @bg.y = ((@player.y / 480.0).floor * 480) + (@player.y * 0.2) % 480
  end

  def draw
    super
    @fuel_level.width = (@player.fuel / @player.max_fuel) * 200


    @font.draw(@player.system, 10, 10, 250, 2.0)
    if @player.target
      @font.draw(@player.target.name, @map_rect.x, @map_rect.y + 220, 250, 0.7)
      dist = Gosu.distance(@player.x, @player.y, @player.target.x, @player.target.y)
      if dist > 1000
        dist = (dist / 100.0).floor / 10.0
        dist = dist.to_s + "Gm"
      else
        dist = dist.floor
        dist = dist.to_s + "Mm"
      end
      @font.draw(dist,
        @map_rect.x + 150, @map_rect.y + 220, 250, 0.5)

      if Planet === @player.target
        width = @player.target.image.width
        height = @player.target.image.height
        fac = 1 / (width / 200.0)
        fac *= @player.target.factor / 3.0
        @player.target.image.draw(@map_rect.x, @map_rect.y + 260 - fac * 60, 250, fac, fac)
      else
        fac = 1
        @player.target.image.draw(@map_rect.x, @map_rect.y + 260, 250, fac, fac)
      end
    end

    fill_rect(@map_rect, Gosu::Color::BLACK, 249)
    draw_rect(@map_rect, Gosu::Color::WHITE, 250)
    fill_rect(@fuel_level, Gosu::Color::GRAY, 250)
    draw_rect(@fuel_rect, Gosu::Color::WHITE, 250)
    game_objects.each do |obj|
      x = @map_rect.x + (obj.x / 100) * 2
      y = @map_rect.y + (obj.y / 100) * 2
      if obj == @player.target
        draw_circle(x, y, 3, Gosu::Color::CYAN)
      end
      case obj
      when Asteroid
        draw_circle(x, y, 1, Gosu::Color::WHITE)
      when Planet
        draw_circle(x, y, obj.factor*2.5, Gosu::Color::BLUE)
      when Player
        draw_circle(x, y, 2, Gosu::Color::GREEN)
      when Npc
        draw_circle(x, y, 2, Gosu::Color::YELLOW)
      end
    end
  end
end
