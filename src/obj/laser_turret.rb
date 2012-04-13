class LaserTurret
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @sound = Gosu::Sample.new("sounds/laser.wav")
    @arc = 180
  end

  def fire
    target = @player.target
    if [Npc, Player].include? target.class
      x, y = Angle.rotate_v(@player.angle, @x, @y)
      tx = @player.x + x
      ty = @player.y + y
      range = Gosu.distance(tx, ty, target.x, target.y)

      @sound.play

      lead = range / 12.0

      goal_angle = Angle.vtoa((target.velocity_x * lead) + target.x - tx, 
                              (target.velocity_y * lead) + target.y - ty)

      diff = Angle.diff(goal_angle, @player.angle) 
      if diff < -@arc
        goal_angle = @player.angle - @arc
      elsif diff > @arc
        goal_angle = @player.angle + @arc
      end

      shot = Laser.create(goal_angle, @player.vx, @player.vy, @player)
      shot.x = @player.x + x
      shot.y = @player.y + y
      shot.angle = goal_angle
    else
      @sound.play
      shot = Laser.create(@player.angle, @player.vx, @player.vy, @player)
      x, y = Angle.rotate_v(@player.angle, @x, @y)
      shot.x = @player.x + x
      shot.y = @player.y + y
      shot.angle = @player.angle
    end
  end

  def cycle
    200
  end
end
