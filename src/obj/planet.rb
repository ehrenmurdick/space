class Planet < Chingu::GameObject
  traits :sprite
  attr_accessor :name, :surface
  def initialize opts = {}
    super({:image => "assets/planet.png"}.merge(opts))
  end
end
