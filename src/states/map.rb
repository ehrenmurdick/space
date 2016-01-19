require 'yaml'
class Map < Chingu::GameState
  traits :viewport, :timer
  attr_accessor :cursor, :target, :player
  def initialize(x, y)
    @x, @y = x, y
    super()
    @systems = YAML.load(File.read("data/systems.yml"))
  end

  def setup
    @bg = Bg.create
    @bg.image = "assets/milkyway2.jpg"
    @bg.factor = 1.7
    @bg.x = 1200
    @bg.y = 1000
    @dist = Chingu::Text.create("", :x => @x, :y => @y + 10, :zorder => 55, :factor_x => 2.0)
    @dist.color = Gosu::Color::RED
    @systems.each do |name, attrs|
      p = Planet.create
      p.factor = 0.1
      p.x = attrs["x"]
      p.y = attrs["y"]
      p.image = "assets/star_#{attrs["color"]}.png"
      p.factor = 0.5
      @text = Chingu::Text.create(name, :x => p.x, :y => p.y + 10, :zorder => 55, :factor_x => 2.0)
      @text.color = Gosu::Color::RED
      # @text.draw
    end

    self.viewport.game_area = [0, 0, 2000, 2000]

    @cursor = Cursor.create
    @cursor.x = @x
    @cursor.y = @y
    @cursor.zorder = 200
    $player = @player

    self.input = {
                  :holding_left => :holding_left,
                  :holding_right => :holding_right,
                  :holding_up => :holding_up,
                  :holding_down => :holding_down}
    after(200) do
      self.input[:released_m] = [lambda { revert }]
      self.input[:released_w] = [lambda { goto }]
    end
  end

  def holding_left
    @cursor.x -= 5
  end

  def holding_right
    @cursor.x += 5
  end

  def holding_down
    @cursor.y += 5
  end

  def holding_up
    @cursor.y -= 5
  end

  def goto
    if @ly > @player.fuel
      Gosu::Sound["negative.wav"].play
      return
    end
    target = @systems.find do |h, k|
      Gosu.distance(k["x"], k["y"], @cursor.x, @cursor.y) < 50
    end
    if target
      $target_system = target.first
      $window.pop_game_state
    else
      Gosu::Sound["negative.wav"].play
    end
  end

  def revert
    $window.pop_game_state
  end

  def button_down(id)
    exit if id == Gosu::Button::KbQ
  end

  def update
    super
    viewport.center_around(@cursor)
    @dist.y = @cursor.y - 10
    @dist.x = @cursor.x + 20
    @ly = Gosu.distance(@x, @y, @cursor.x, @cursor.y)
    @dist.text = @ly.round(2)
  end

  def draw
    super
    draw_circle(@x - viewport.x, @y - @viewport.y, @player.fuel, Gosu::Color::RED)
    draw_circle(@x - viewport.x, @y - @viewport.y, @player.fuel/2, Gosu::Color::GREEN)
  end
end
