class Board

  def initialize(**args)
    valid_attrs = [:max_up, :max_down, :max_left, :max_right]

    extra_attrs = args.keys - valid_attrs

    raise "Invalid attrs #{extra_attrs.join(',')}" if extra_attrs.length > 0

    [:max_up, :max_down, :max_left, :max_right].each do |arg|
      instance_variable_set("@#{arg}", args[arg])
    end
    raise "max_down must be less than or equal to 0" if (@max_down && @max_down > 0)
    raise "max_left must be less than or equal to 0" if (@max_left && @max_left > 0)
    raise "max_up must be greater than or equal to 0" if (@max_up && @max_up < 0)
    raise "max_right must be greater than or equal to 0" if (@max_right && @max_right < 0)
  end

  def location_out_of_bounds(x_coordinate, y_coordinate)
    if !@max_up.nil? && y_coordinate > @max_up
      Location::NORTH
    elsif !@max_down.nil? && y_coordinate < @max_down
      Location::SOUTH
    elsif !@max_right.nil? && x_coordinate > @max_right
      Location::EAST
    elsif !@max_left.nil? && x_coordinate < @max_left
      Location::WEST
    end
  end

end
