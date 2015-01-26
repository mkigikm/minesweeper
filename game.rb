require 'dispel'
require './minesweeper_board.rb'
require 'yaml'

class Game
  attr_reader :position, :board

  def self.load(file_name = 'minesweeper.txt')
    return nil unless File.file?(file_name)

    serialized_game = File.read(file_name)
    game = YAML::load(serialized_game)
    return nil unless game.is_a?(Game)
    game
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
  MAIN_MENU = [
    "Welcome to Minesweeper!",
    "(B)eginner",
    "(I)ntermediate",
    "(E)xpert",
    "(C)ustom",
    "(L)oad",
    "Le(a)derboard",
    "E(x)it"
  ]

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

  def run_game(game)

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
        when "s"
          game.save('minesweeper.txt')
          break
        end

        display_game(screen, game)
      end
    end
  end

  def display_main_menu
    MAIN_MENU.join("\n")
  end


  # "Welcome to Minesweeper!",
  # "(B)eginner",
  # "(I)ntermediate",
  # "(E)xpert",
  # "(C)ustom",
  # "(L)oad",
  # "Le(a)derboard",
  # "E(x)it"


  def run_main_menu
    Dispel::Screen.open do |screen|
      screen.draw(display_main_menu)

      Dispel::Keyboard.output do |key|
        case key
        when 'b' then run_game(Game.new(9, 9, 10))
        when 'i' then run_game(Game.new(16, 16, 40))
        when 'e' then run_game(Game.new(16, 30, 99))
        when 'c' then break
        when 'l'
          game = Game.load
          run_game(game) unless game.nil?
        when 'a' then break
        when 'x' then exit
        end

        screen.draw(display_main_menu)
      end
    end
  end

  def leaderboard
  end

  def custom_settings
  end

end


if __FILE__ == $PROGRAM_NAME

  display = Display.new

  display.run_main_menu

end
