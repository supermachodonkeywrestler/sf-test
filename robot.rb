class Robot

  attr_accessor :orientation, :location

  LOCATION_ORDER = [ Location::NORTH, Location::EAST, Location::SOUTH, Location::WEST ]

  MOVEMENT_MAPPINGS = {
    Location::NORTH => [0,1],
    Location::EAST => [1,0],
    Location::SOUTH => [0,-1],
    Location::WEST => [-1,0]
  }

  def initialize
    reset
  end

  def x_location
    @location[0]
  end

  def y_location
    @location[1]
  end

  def turn_left
    if (new_idx = LOCATION_ORDER.index(@orientation) - 1) < 0
      new_idx = LOCATION_ORDER.length - 1
    end
    @orientation =  LOCATION_ORDER[new_idx]
  end

  def turn_right
    if (new_idx = LOCATION_ORDER.index(@orientation) + 1) > last_index
      new_idx = 0
    end
    @orientation =  LOCATION_ORDER[new_idx]
  end

  def next_move_location
    [ MOVEMENT_MAPPINGS[@orientation][0] + x_location, MOVEMENT_MAPPINGS[@orientation][1] + y_location ]
  end

  def move_forward
    @location = next_move_location
  end

  def reset
    @orientation = Location::NORTH
    @location = [0,0]
  end

  private
  def last_index
    @last_index ||= LOCATION_ORDER.length - 1
  end

end
