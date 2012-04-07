class Planet < Chingu::GameObject
  traits :sprite
  def initialize
    self.scale = 10
    super(:image => "assets/planet.png")
  end
end
