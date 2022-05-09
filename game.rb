class Game
  COMMANDS = {
    "L" => :turn_robot_left,
    "R" => :turn_robot_right,
    "M" => :move_robot_forward,
    "?" => :help_message,
    "Q" => :quit
  }

  def self.start(passed_input=[])
    
    get_input = -> { passed_input.shift || gets.strip }

    puts "Do you want to set a max size for the plane? (y/n)"

    max_size = nil

    if get_input.call == 'y'
      while true
        puts "Enter max size (int value greater than 0)"
        max_size = get_input.call
        break if max_size.to_i > 0
        puts "Invalid value for max size."
      end
    end

    game = new(max_size.nil? ? nil : max_size.to_i)

    while true
      print '>'
      cmd = get_input.call
      unless game.valid_cmd?(cmd)
        puts "Invalid command"
        next
      end

      begin
        game.execute_cmd(cmd)
      rescue => e
        puts e.message
        next
      end

      break if game.quit_now?
    end

    puts "Thanks for playing"
  end

  def valid_cmd?(cmd)
    COMMANDS.keys.include?(cmd)
  end

  def execute_cmd(cmd)
    send(COMMANDS[cmd])
  end

  def initialize(board_size)
    @board = if board_size.nil?
      Board.new
    else 
      Board.new(max_up: board_size, max_down: -board_size, max_right: board_size, max_left: -board_size)
    end
    @robot = Robot.new
  end

  def move_robot_forward
    is_bad_location = @board.location_out_of_bounds(*@robot.next_move_location)
    if is_bad_location
      raise self.class.bad_location_message(is_bad_location)
    end
    @robot.move_forward
    puts self.class.where_is_the_robot_message(@robot.x_location, @robot.y_location, @robot.orientation)
  end

  def turn_robot_left
    @robot.turn_left
    puts self.class.where_is_the_robot_message(@robot.x_location, @robot.y_location, @robot.orientation)
  end

  def turn_robot_right
    @robot.turn_right
    puts self.class.where_is_the_robot_message(@robot.x_location, @robot.y_location, @robot.orientation)
  end

  def self.bad_location_message(bad_location)
    "Too far #{bad_location}"
  end

  def self.where_is_the_robot_message(x_location, y_location, orientation)
    "Robot at (#{x_location}, #{y_location}) facing #{orientation}"
  end

  def help_message
    puts self.class.help_message_output
  end

  def self.help_message_output
    <<-DOC
    Command the robot with:
    L - turn left
    R - turn right
    M - move forward
    ? - this message
    Q - quit
    DOC
  end

  def quit
    @quit = true
  end

  def quit_now?
    @quit
  end

end
