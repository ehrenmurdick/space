class Cursor < Chingu::GameObject
  traits :sprite
  def initialize
    super(:image => "assets/cross.png")
  end

  def vx=(n)
    @velocity_x = n
  end

  def vy=(n)
    @velocity_y = n
  end

  def setup
    self.factor = 1
  end
end
