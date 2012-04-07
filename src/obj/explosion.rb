class Explosion < Chingu::GameObject
  traits :sprite, :timer
  def initialize
    super(:image => "assets/explosion.png")
  end

  def setup
    after(300) do
      destroy
    end
  end
end
