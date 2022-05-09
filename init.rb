require_relative 'location.rb'
require_relative 'robot.rb'
require_relative 'board.rb'
require_relative 'game.rb'
require_relative 'tester.rb'

puts "Press 'T' to run test suite, or 'G' to play game"

while (input = gets.strip)
  if ['T', 'G'].include?(input)
    break
  else
    puts "Invalid Entry"
  end
end

input == 'T' ? Tester.run_test_suite : Game.start
