class Planet < Chingu::GameObject
  traits :sprite
  attr_accessor :name
  def initialize opts = {}
    super({:image => "assets/planet.png"}.merge(opts))
  end
end
