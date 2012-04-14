class Planet < Chingu::GameObject
  traits :sprite
  attr_accessor :name, :surface
  def initialize opts = {}
    super({:image => "assets/planet.png"}.merge(opts))
  end

  def surface=(name)
    unless name
      @surface = nil
      return
    end
    @surface = Gosu::Image["assets/planets/#{name}"]
  end
end
