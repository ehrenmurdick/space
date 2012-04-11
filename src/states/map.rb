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
    @systems.each do |name, attrs|
      p = Planet.create
      p.factor = 0.1
      p.x = attrs["x"]
      p.y = attrs["y"]
      p.image = "assets/planets/#{attrs["planets"].first[1]["image"]}"
      @text = Chingu::Text.create(name, :x => p.x, :y => p.y + 10, :zorder => 55, :factor_x => 2.0)
      @text.draw
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
    @cursor.x -= 10
  end

  def holding_right
    @cursor.x += 10
  end

  def holding_down
    @cursor.y += 10
  end

  def holding_up
    @cursor.y -= 10
  end

  def goto
    target = @systems.find do |h, k|
      Gosu.distance(k["x"], k["y"], @cursor.x, @cursor.y) < 50
    end
    if target
      $target_system = target.first
      $window.pop_game_state
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
  end
end
