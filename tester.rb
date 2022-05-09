require 'timeout'

class Tester

  def self.run_test_suite
    t = Tester.new

    puts "Testing Robot ************************"
    r = t.test_robot

    failed_cases = r.select{|results| !results[0]}

    if failed_cases.length > 0
      puts "**********Failed cases:"
      failed_cases.each{|result| puts "#{result}\n\n"}
    else
      puts "**********All passed"
    end

    puts "Testing Board ***********************"

    b = t.test_board

    failed_cases = b.select{|results| !results[0]}

    if failed_cases.length > 0
      puts "**********Failed cases:"
      failed_cases.each{|result| puts "#{result}\n\n"}
    else
      puts "**********All passed"
    end

    puts "Testing Game ************************"

    input_output_test_data = [
      ['n', nil],
      ['M', ">#{Game.where_is_the_robot_message(0,1,'North')}"],
      ['L', ">#{Game.where_is_the_robot_message(0,1,'West')}"],
      ['M', ">#{Game.where_is_the_robot_message(-1,1,'West')}"],
      ['M', ">#{Game.where_is_the_robot_message(-2,1,'West')}"],
      ['L', ">#{Game.where_is_the_robot_message(-2,1,'South')}"],
      ['M', ">#{Game.where_is_the_robot_message(-2,0,'South')}"],
      ['R', ">#{Game.where_is_the_robot_message(-2,0,'West')}"],
      ['R', ">#{Game.where_is_the_robot_message(-2,0,'North')}"],
      ['R', ">#{Game.where_is_the_robot_message(-2,0,'East')}"],
      ['M', ">#{Game.where_is_the_robot_message(-1,0,'East')}"],
      ['F', '>Invalid command'],
      ['?', ">#{Game.help_message_output}"],
      ['Q', '>Thanks for playing']
    ]

    g = t.test_game(input_output_test_data)

    if g.length > 0
      puts "**********Failed output matches:"
      g.each{|result| puts "#{result}\n\n"}
    else
      puts "**********All passed"
    end

    puts "Testing Game with custom board size ******************"

    input_output_test_data = [
      ['y', 'Enter max size (int value greater than 0)'],
      ['1', nil ],
      ['M', ">#{Game.where_is_the_robot_message(0,1,'North')}"],
      ['M', ">Too far North"],
      ['Q', '>Thanks for playing']
    ]

    g = t.test_game(input_output_test_data)

    if g.length > 0
      puts "**********Failed output matches:"
      g.each{|result| puts "#{result}\n\n"}
    else
      puts "**********All passed"
    end
    true
  end

  def test_robot
    results = []
    robot = Robot.new
    results << run_test(0) { robot.x_location }
    results << run_test(0) { robot.y_location }

    #turn_right tests
    [
      [ Location::NORTH, Location::EAST ],
      [ Location::EAST, Location::SOUTH ],
      [ Location::SOUTH, Location::WEST ],
      [ Location::WEST, Location::NORTH ]
    ].shuffle.each do |start_finish|
      robot.reset
      robot.orientation = start_finish[0]
      results << run_test(start_finish[1]) { robot.turn_right }
    end

    #turn_left tests
    [
      [ Location::EAST, Location::NORTH ],
      [ Location::SOUTH, Location::EAST ],
      [ Location::WEST, Location::SOUTH ],
      [ Location::NORTH, Location::WEST ]
    ].shuffle.each do |start_finish|
      robot.reset
      robot.orientation = start_finish[0]
      results << run_test(start_finish[1]) { robot.turn_left }
    end

    #move tests
    [
      [ Location::NORTH, [0, 1] ],
      [ Location::WEST, [-1, 0] ],
      [ Location::SOUTH, [0, -1] ],
      [ Location::EAST, [1, 0] ]
    ].shuffle.each do |orientation_location|
      robot.reset
      robot.orientation = orientation_location[0]
      results << run_test(orientation_location[1]) { robot.next_move_location }
      results << run_test(orientation_location[1]) { robot.move_forward; robot.location }
    end

    results
  end

  def test_board
    results = []

    # no bounds tests
    board = Board.new
    [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ].shuffle.each do |location|
      results << run_test(nil) { board.location_out_of_bounds(*location) }
    end

    # equal bounds tests
    board = Board.new(max_up: 1, max_down: -1, max_right: 1, max_left: -1)
    [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ].shuffle.each do |location|
      results << run_test(nil) { board.location_out_of_bounds(*location) }
    end

    #out of bounds tests
    board = Board.new(max_up: 1, max_down: -1, max_right: 1, max_left: -1)
    [
      [ Location::NORTH, [0, 2] ],
      [ Location::EAST, [2, 0] ],
      [ Location::SOUTH, [0, -2] ],
      [ Location::WEST, [-2, 0] ]
    ].shuffle.each do |result_location|
      results << run_test(result_location[0]) { board.location_out_of_bounds(*result_location[1]) }
    end

    # bad init test
    [
      [ "max_down must be less than or equal to 0", {max_down: 1} ],
      [ "max_left must be less than or equal to 0", {max_left: 1} ],
      [ "max_up must be greater than or equal to 0", {max_up: -1} ],
      [ "max_right must be greater than or equal to 0", {max_right: -1} ],
      [ "Invalid attrs cheese", {cheese: 'x'} ] 
    ].shuffle.each do |msg_bounds|
      results << catch_exception_test(msg_bounds[0]) { Board.new(**msg_bounds[1]) }
    end

    results
  end

  def test_game(input_output_test_data, output_game=true)
    # kill after 5 seconds, otherwise game runs indefinitely, so end command_input with a 'Q'.
    # TODO - potentially add Q if not there, and omit output.
    
    #get_commands
    command_input = input_output_test_data.map{|io| io[0]}

    game_out = Timeout.timeout(5) do
      with_captured_stdout { Game.start(command_input) }
    end

    print game_out if output_game

    #split all new lines into array
    game_out_split = game_out.split("\n")
    
    #this always starts the game
    game_start_output = "Do you want to set a max size for the plane? (y/n)"
    
    expected_output = [game_start_output].concat(input_output_test_data.map{|io| io[1]}).compact

    expected_output.map!{|eo| eo.split("\n")}.flatten!

    no_match = []

    for i in 0...(expected_output.length - 1) do
      if game_out_split[i] != expected_output[i]
        no_match << "Got '#{expected_output[i]}'\nExpected '#{game_out_split[i]}'"
      end
    end

    no_match
  end

  def run_test(expected_result)
    which_test = caller[0]
    begin
      result = yield
      if result == expected_result
        return [ true, which_test ]
      else
        msg = "#{which_test} failed.  Got #{result} expected #{expected_result}"
        return [ false, msg ]
      end
    rescue => e
      msg = "#{which_test} failed.  Exception #{e.message}\n#{e.backtrace}"
      return [ false, msg ]
    end
  end

  def catch_exception_test(expected_message)
    which_test = caller[0]
    begin 
      yield
      [ false, "Expected exception #{expected_message} for #{which_test}" ]
    rescue => e
      if e.message == expected_message
        [ true, which_test ]
      else
        [ false, "Expected exception '#{expected_message}', got '#{e.message}' for #{which_test}"]
      end
    end
  end

  #credit where due https://stackoverflow.com/questions/14987362/how-can-i-capture-stdout-to-a-string
  def with_captured_stdout
    original_stdout = $stdout  # capture previous value of $stdout
    $stdout = StringIO.new     # assign a string buffer to $stdout
    yield                      # perform the body of the user code
    $stdout.string             # return the contents of the string buffer
  ensure
    $stdout = original_stdout  # restore $stdout to its previous value
  end

end
