#!/usr/bin/env ruby
# coding : utf-8

=begin

Sample input file:

200643000
008000001
000500006
000020070
081009000
000050000
503001000
040300068
000000020

How to run
./sudoku.rb <input file name>

=end

class Sudoku
  SIZE = 9
  BLOCK_SIZE = SIZE/3

  def initialize(lines)
    @matrix = lines.reduce([]) {|matrix, line| matrix << line.split('').collect{|n| n.to_i}}

    # @row_state[i][j] == 1 : if Row i already has Number j+1
    @row_state = (0...SIZE).map{(0...SIZE).map{0}}

    # @column_state[i][j] == 1 : if Column i already has Number j+1
    @column_state = (0...SIZE).map{(0...SIZE).map{0}}

    # block_state[i][j] == 1 : if Block i already has Number j+1
    @block_state = (0...SIZE).map{(0...SIZE).map{0}}

    (0...SIZE).each do |i|
      (0...SIZE).each do |j|
        if @matrix[i][j] != 0
          number = @matrix[i][j]-1
          @row_state[i][number] = 1
          @column_state[j][number] = 1
          @block_state[block_id(i,j)][number] = 1
        end
      end
    end
  end

  def solve
    result = try_to_fill(0)

    if result == false
      puts "No solution found."
      exit
    end
    
    (0...SIZE).each do |i|
      (0...SIZE).each do |j|
        print @matrix[i][j]
      end
      puts
    end
  end

  private

  def try_to_fill(n)
    return true if n == SIZE * SIZE

    x = n / SIZE
    y = n % SIZE

    bid = block_id(x,y)      
    number = @matrix[x][y]-1

    if @matrix[x][y] == 0
      (0...SIZE).each do |i|
        if @row_state[x][i] == 0 && @column_state[y][i] == 0 && @block_state[bid][i] == 0
          
          @matrix[x][y] = i+1
          
          @row_state[x][i] = @column_state[y][i] = @block_state[bid][i] = 1
          return true if try_to_fill(n+1)
          @row_state[x][i] = @column_state[y][i] = @block_state[bid][i] = 0

          @matrix[x][y] = 0
        end
      end
    elsif @row_state[x][number] == 1 && @column_state[y][number] == 1 && @block_state[bid][number] == 1
      return try_to_fill(n+1)
    end

    false
  end

  # Returns a block ID corresponding Row i and Column j
  def block_id(i, j)
    x = i - i % BLOCK_SIZE
    y = j - j % BLOCK_SIZE
    x + y/3    
  end
end

# Main function

if ARGV.empty?
  print "Usage: ./sudoku.rb <filename>\n"
  exit
end

lines = File.read(ARGV[0]).split("\n")
sudoku = Sudoku.new(lines)
sudoku.solve
