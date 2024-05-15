require './skyscrapers'

clues_list = [
  [ 7,0,0,0,2,2,3, 0,0,3,0,0,0,0, 3,0,3,0,0,5,0, 0,0,0,0,5,0,4 ],
  [ 0,2,3,0,2,0,0, 5,0,4,5,0,4,0, 0,4,2,0,0,0,6, 5,2,2,2,2,4,1 ],
  [ 0,0,0,5,0,0,3, 0,6,3,4,0,0,0, 3,0,0,0,2,4,0, 2,6,2,2,2,0,0 ],
  [ 3,3,2,1,2,2,3, 4,3,2,4,1,4,2, 2,4,1,4,5,3,2, 3,1,4,2,5,2,3 ]
]

expected_results = [
  [ [1,5,6,7,4,3,2], [2,7,4,5,3,1,6], [3,4,5,6,7,2,1], [4,6,3,1,2,7,5], [5,3,1,2,6,4,7], [6,2,7,3,1,5,4], [7,1,2,4,5,6,3] ],
  [ [7,6,2,1,5,4,3], [1,3,5,4,2,7,6], [6,5,4,7,3,2,1], [5,1,7,6,4,3,2], [4,2,1,3,7,6,5], [3,7,6,2,1,5,4], [2,4,3,5,6,1,7] ],
  [ [3,5,6,1,7,2,4], [7,6,5,2,4,3,1], [2,7,1,3,6,4,5], [4,3,7,6,1,5,2], [6,4,2,5,3,1,7], [1,2,3,4,5,7,6], [5,1,4,7,2,6,3] ],
  [ [2,1,4,7,6,5,3], [6,4,7,3,5,1,2], [1,2,3,6,4,7,5], [5,7,6,2,3,4,1], [4,3,5,1,2,6,7], [7,6,2,5,1,3,4], [3,5,1,4,7,2,6] ]
]


time_start = Time.now

clues_list.each_with_index do |clues, index|
  local_time_start = Time.now

  s = Skyscrapers.new(clues: clues)
  s.main_process
  s.guess unless s.solved?

  if s.grid == expected_results[index]
    puts "Puzzle ##{index + 1} was solved in #{Time.now - local_time_start} seconds"
  else
    puts "OMG!!! it doesn't work, call BugBusters"
  end
end

puts "Total time is #{Time.now - time_start} seconds"
