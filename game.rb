require 'dispel'
require './minesweeper_board.rb'

class Game
  attr_reader :position, :board

  def initialize(rows, columns, bombs)
    @board = Board.new(rows, columns, bombs)
    @row_count = rows
    @coulmn_count = columns
    @position = [0, 0]
  end

  def up
    @position[0] -= 1 unless @position[0] == 0
  end

  def down
    @position[0] += 1 unless @position[0] ==  @row_count - 1
  end

  def left
    @position[1] -= 1 unless @position[1] == 0
  end

  def right
    @position[1] += 1 unless @position[1] ==  @column_count - 1
  end
end

class Display
  def run
    game = Game.new(9,9,10)

    Dispel::Screen.open do |screen|
      screen.draw(game.board.display, [], game.position)

      Dispel::Keyboard.output do |key|
        case key
        when :up then game.up
        when :left then game.left
        when :right then game.right
        when :down then game.down
        when "q" then break
        when "r" then game.board.reveal(game.position)
        when "f" then game.board.flag(game.position)
        end

      screen.draw(game.board.display, [], game.position)
      end
    end
  end

end


if __FILE__ == $PROGRAM_NAME

  display = Display.new

  display.run

end
