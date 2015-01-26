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

  def reveal_first
    # raise "can't reveal a flagged tile" if @flagged

    return :safe if revealed || flagged
    return :exploded if @bomb

    @revealed = true
    if neighbors.none?(&:bomb)
     neighbors.each do |neighbor|
       neighbor.reveal
     end
    end

    :safe
  end

  def reveal
    return if revealed || flagged
    @revealed = true
    return if number > 0
    neighbors.each do |neighbor|
      neighbor.reveal
    end

  end

  def neighbors
    @board.neighbors(@location)
  end

  def inspect
    @location.inspect
  end

  def num_as_string
    if number == 0
      "."
    else
      number.to_s
    end
  end

  def display(over)
    unless over
      if revealed
        num_as_string
      elsif flagged
        Board::FLAG
      else
        Board::UNEXPLORED
      end
    else
      if bomb
        Board::BOMB
      else
        num_as_string
      end
    end
  end
end

class Board
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
  UNEXPLORED = "-"
  BOMB = "*"
  FLAG = "^"

  attr_reader :alive

  def self.randomize_bombs(rows, columns, bomb_count)
    locations = [true] * bomb_count + [false] * (rows * columns - bomb_count)
    locations.shuffle!
  end

  def self.empty_dimensions(row_count, column_count)
    Array.new(row_count) { Array.new(column_count)}
  end

  def initialize(rows, columns, bomb_count)
    bomb_locations = self.class.randomize_bombs(rows, columns, bomb_count)
    @tiles = self.class.empty_dimensions(rows, columns)
    @row_count = rows
    @column_count = columns
    @bomb_count = bomb_count
    @alive = true

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

    @alive = false if @tiles[row][column].reveal_first == :exploded
  end

  def won?
    revelead_tile_count = @tiles.flatten.select { |tile| tile.revealed}.count
    revelead_tile_count == @row_count * @column_count - @bomb_count
  end

  def loss?
    !alive
  end

  def display
    revealed_display = ""

    @row_count.times do |row|
      @column_count.times do |column|
        revealed_display << @tiles[row][column].display(won? || loss?)
      end
      revealed_display << "\n"
    end

    revealed_display
  end
end
