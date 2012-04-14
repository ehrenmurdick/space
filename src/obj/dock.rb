require './src/obj/planet'
class Dock < Planet
  def initialize opts = {}
    super(:image => "assets/planets/station.png")
  end
end
