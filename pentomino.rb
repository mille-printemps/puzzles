#!/usr/bin/env ruby
# coding : utf-8

=begin

Sample input file:
- The first line: height and width of the box
- Each line of the rest: height and width of a rectangle block put in the box

4 3
1 2
1 1
1 1
2 1
3 2

How to run:
./pentomino.rb <input file name>

Constraints:
The number of blocks that can be used is 62. (from 'A' to '~' in the order of Unicode)
[A-Za-z[]\^_`{}|~]

=end

class Point
  def initialize(r,c)
    @r = r
    @c = c
  end

  attr_reader :r, :c
end

# A block is represented by a collection of points. 
# e.g. 1*2 block is [[0,0],[0,1]], 2*2 block is [[0,0],[0,1],[1,0],[1,1]]
class Block

  def initialize(id, row, column)
    @id = id
    @size = Point.new(row, column)
    
    @points = []
    (0...row).each do |i|
      (0...column).each do |j|
        @points << Point.new(i,j)
      end
    end
  end
  
  attr_reader :id, :size, :points
  
end


class Box
  SPACE = '.'
  INITIAL_ID = 'A'
  
  def initialize(height, width, points)
    @height = height
    @width = width
    @box = (0...height).map {(0...width).map{SPACE}}

    id = INITIAL_ID
    @blocks = []
    points.each do |point|
      @blocks << Block.new(id, point.r, point.c)
      id = next_id(id)
    end

    # @used['A'] == true : if Block A has already been put in the box
    @used = @blocks.reduce({}) {|used, block| used.merge(block.id => false)}

    # @done : the number of blocks that have already been put in the box
    @done = 0

    # @solutions : list of solutions
    @solutions = []
  end

  def solve
    unless can_accomodate?
      puts "No solution found."
      exit
    end

    try_to_put(0, 0)
    
    @solutions.sample unless @solutions.size == 0
  end

  attr_reader :height, :width, :blocks

  private

  def next_id(id)
    [id.unpack("U")[0]+1].pack("U")
  end

  def try_to_put(r, c)
    if @done == @blocks.size
      @solutions << Marshal.load(Marshal.dump(@box))
      return
    end
    
    s,t = next_space(r,c)
    @blocks.each do |block|
      if @used[block.id] == false && can_put?(block,s,t)
        put(block,s,t)
        @used[block.id] = true
        @done += 1

        try_to_put(s,t)

        remove(block,s,t)
        @used[block.id] = false
        @done -= 1
      end
    end
  end

  def put(block, r, c)
    (0...block.points.size).each do |i|
      @box[r + block.points[i].r][c + block.points[i].c] = block.id
    end
  end

  def remove(block, r, c)
    (0...block.points.size).each do |i|
      @box[r + block.points[i].r][c + block.points[i].c] = SPACE
    end
  end

  def display
    (0...@height).each do |i|
      (0...@width).each do |j|
        print @box[i][j]
      end
      puts
    end
  end

  def next_space(r, c)
    while true
      return r, c if @box[r][c] == SPACE
      c += 1
      if @width <= c
        r += 1
        c = 0
      end
    end
  end

  def can_put?(block, r, c)
    (0...block.points.size).each do |i|
      s = r + block.points[i].r
      t = c + block.points[i].c
      return false unless in_box?(s,t)
      return false unless @box[s][t] == SPACE
    end
    true
  end

  def in_box?(r, c)
    return false if r < 0 || @height <= r
    return false if c < 0 || @width <= c
    true
  end

  def can_accomodate?
    total_area = @blocks.reduce(0) {|sum, block| sum += block.size.r * block.size.c}
    total_area == @height * @width
  end
  
end

class Formatter
  SOLUTION_HTML =<<-SOLUTION
<html>
<body>

  <head>
    <title>Solution</title>

    <style type="text/css">
      div { display: table-cell; text-align: center; vertical-align: middle; }
      li {list-style: none;}
      #panel {margine: 0 auto; width: 510px;}
      #blocks {float: left; width: 200px;}
      #arrow {float: left; width: 10px; font-size: x-large}
      #solution {float: left; width: 300px;}
    </style>
    
  </head>

  <div id="panel" class="panel">

    <div id="blocks" class="blocks">
      <ul>
      %s
      </ul>
    </div>

   <div id="arrow" class="arrow">
      <ul>
        <li>
        =>
        </li>
      </ul>
   </div>

    <div id="solution" class="solution">
      <ul>
        <li>
        %s
        </li>
      </ul>
    </div>
  </div>
  
  </body>
</html>
SOLUTION

  
  def initialize(blocks, solution)
    @blocks = blocks
    @solution = solution
    @solution_html = SOLUTION_HTML
  end

  def html
    blocks = ""
    @blocks.each do |block|
      r,c = block.size.r,block.size.c
      blocks += "<li>\n"
      
      (0...r).each do |i|
        (0...c).each  do |j|
          blocks += block.id
        end
        blocks += "<br>\n"
      end

      blocks += "</li>\n"
      blocks += "(%s &times; %s)\n<p>\n" % [r, c]
    end

    solution = ""
    @solution.each do |row|
      row.each do |id|
        solution += id
      end
      solution += "<br>\n"
    end
    solution += "(%s &times; %s)<br>\n" % [@solution.size, @solution[0].size]

    @solution_html % [blocks, solution]    
  end
  
end

# Main function

if ARGV.empty?
  print "Usage: ./pentomino.rb <filename>\n"
  exit
end

lines = File.read(ARGV[0]).split("\n")
i = 0
height = 0
width = 0
points = []
lines.each do |line|
  if i == 0
    h,w = line.split(' ')
    height,width = h.to_i,w.to_i
    i += 1
  else
    r,c = line.split(' ')
    points << Point.new(r.to_i,c.to_i)
  end
end

box = Box.new(height,width,points)
solution = box.solve

unless solution == nil
  formatter = Formatter.new(box.blocks, solution)
  print formatter.html
end
