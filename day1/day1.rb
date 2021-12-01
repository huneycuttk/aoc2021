depths = File.open("/Users/kph/Stuff/aoc2021/day1/input.txt") { |f| f.each_line.map { |l| l.to_i } }

puts "Read #{depths.count} depths"

inc_depths = depths.each_cons(2).reduce(0) { |count, (a, b)| b > a ? count + 1 : count }

inc_windows = depths.each_cons(3).map { |a,b,c| a+b+c }.each_cons(2).reduce(0) { |count, (a, b)| b > a ? count + 1 : count }

puts "#{inc_depths} #{inc_windows}"
