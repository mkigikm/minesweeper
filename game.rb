require 'dispel'
require './minesweeper_board.rb'
require 'yaml'

class Game
  attr_reader :position, :board

  def self.load(file_name = 'minesweeper.txt')
    serialized_game = File.read(file_name)
    YAML::load(serialized_game)
  end

  def initialize(rows, columns, bombs)
    @board = Board.new(rows, columns, bombs)
    @row_count = rows
    @column_count = columns
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

  def save(file_name)
    File.open(file_name, 'a') do |f|
      f.puts self.to_yaml
    end
  end

end

class Display
  def display_game(screen, game)
    if game.board.won? || game.board.loss?
      game_board = game.board.display_solution
    else
      game_board = game.board.display
    end

    if game.board.won?
      game_board << "\nWin!"
    elsif game.board.alive
      game_board << "\nAlive"
    else
      game_board << "\nYou dead :("
    end

    game_board << "\n (f)lag (space)reveal (q)uit"

    screen.draw(game_board, [], game.position)
  end

  def run
    game = Game.new(9,9,5)

    Dispel::Screen.open do |screen|
      display_game(screen, game)

      Dispel::Keyboard.output do |key|
        case key
        when :up then game.up
        when :left then game.left
        when :right then game.right
        when :down then game.down
        when "q" then break
        when " " then game.board.reveal(game.position)
        when "f" then game.board.flag(game.position)
        when "s" then game.save('minesweeper.txt')
        end

        display_game(screen, game)
      end
    end
  end

end


if __FILE__ == $PROGRAM_NAME

  display = Display.new

  display.run

end
