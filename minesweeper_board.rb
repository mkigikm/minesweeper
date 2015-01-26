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
    @row_count = rows
    @column_count = columns
    @bomb_count = bomb_count

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
    neighbors = []

    DELTAS.each do |delta|
      delta_row, delta_column = *delta
      new_row, new_column = row + delta_row, column + delta_column

      if new_row.between?(0, @row_count - 1) &&
          new_column.between?(0, @column_count - 1)
        neighbors << @tiles[new_row][new_column]
      end
    end

    neighbors
  end

  def flag(location)
    row, column = *location

    @tiles[row][column].flag
  end

  def reveal(location)
    row, column = *location

    @tiles[row][column].reveal
  end

  def won?
    revelead_tile_count = @tiles.flatten.select { |tile| tile.revealed}.count
    revelead_tile_count == @row_count * @tile_count - @bomb_count
  end
end
