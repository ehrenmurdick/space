class Planet < Chingu::GameObject
  traits :sprite
  attr_accessor :name
  def initialize
    super(:image => "assets/planet.png")
  end
end
