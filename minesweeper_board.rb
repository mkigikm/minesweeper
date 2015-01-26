class Tile
  attr_reader :flagged, :bomb, :revealed

  def initialize(bomb, board, location)
    @bomb = bomb
    @board = board
    @location = location
    @revealed = false
    @flagged = false
  end

  def flag
    @flagged = !@flagged
  end

  def number
    neighbors.select do |neighbor|
      neighbor.bomb
    end.count
  end

  def reveal(first=true)
    raise "can't reveal a flagged tile" if @flagged

    return :safe if revealed
    @revealed = true
    return :exploded if @bomb
    return :safe if number > 0

    not_safe = neighbors.any? do |neighbor|
      neighbor.reveal(false) == :exploded
    end

    if not_safe
      :exploded
    else
      :safe
    end
  end

  def neighbors
    @board.neighbors(@location)
  end
end

def Board
  DELTAS = [
    [1,1],
    [1,0],
    [0,1],
    [-1,0],
    [0,-1],
    [-1,-1],
    [1,-1],
    [-1,1]
  ]

  def self.randomize_bombs(rows, columns, bomb_count)
    locations = [true] * bomb_count + [false] * (rows * columns - bomb_count)
    locations.shuffle!
  end

  def initialize(rows, columns, bomb_count)
    bomb_locations = self.class.randomize_bombs(rows, columns, bomb_count)
    @tiles = Array.new(rows) { Array.new(columns)}

    rows.times do |row|
      columns.times do |column|
        location = [row, column]
        bomb = bomb_locations[row*rows + column]
        @tiles[row][column] = Tile.new(bomb, self, location)
      end
    end
  end

  def neighbors(location)
    row, column = *location
  end



end
