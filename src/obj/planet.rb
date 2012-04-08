class Planet < Chingu::GameObject
  traits :sprite
  def initialize
    super(:image => "assets/planet.png")
  end
end
