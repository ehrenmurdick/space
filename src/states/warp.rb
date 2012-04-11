require 'yaml'
require './src/obj/npc'
class Warp < Chingu::GameState
  traits :viewport, :timer
  attr_accessor :player
  attr_reader :danger, :song
  def initialize(old_system, new_system)
    super()
    @old_system = YAML.load(File.read("data/systems.yml"))[old_system]
    @new_name = new_system
    @new_system = YAML.load(File.read("data/systems.yml"))[new_system]
    $danger = Gosu::Song["assets/music/danger.wav"]
    @song = Gosu::Song["assets/music/planet2.wav"]
    $state = self
    @song.play(true)
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #

    self.viewport.game_area = [0, 0, 10_000, 10_000] 


    @player = Player.create
    @player.x = 4500
    @player.y = 4500
    @player.angle = 0
    @player.zorder = 200
    $player = @player

    @bg = Bg.create
    @bg.image = Gosu::Image["assets/warp.png"]
  end    

  def button_down(id)
    exit if id == Gosu::Button::KbQ
  end

  def setup
    dist = Gosu.distance(@old_system["x"], @old_system["y"], @new_system["x"], @new_system["y"])
    after((dist/@player.warp_speed)*50) do
      new_state = Space.new(@new_name)
      new_state.player.x = 640
      new_state.player.y = 480
      new_state.player.velocity_x = @player.velocity_x
      new_state.player.velocity_y = @player.velocity_y
      new_state.player.angle = @player.angle
      new_state.player.ship = @player.ship
      new_state.player.thruster = false
      new_state.player.fuel = @player.fuel - dist
      $window.switch_game_state(new_state)
    end
  end

  def update
    super
    viewport.center_around(@player)
    @bg.x = ((@player.x / 640.0).floor * 640) + (@player.x * 0.2) % 640
    @bg.y = ((@player.y / 480.0).floor * 480) + (@player.y * 0.2) % 480
  end
end
