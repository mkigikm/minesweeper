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
  end

  def reveal(first=true)
    raise "can't reveal a flagged tile" if @flagged

    return :safe if revealed
    @revealed = true
    return :exploded if @bomb

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
