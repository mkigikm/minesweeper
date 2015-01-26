# encoding: utf-8
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
    "(S)et custom",
    "(L)oad",
    "Le(a)derboard",
    "E(x)it"
  ]
  CUSTOM_MENU = [
    "Custom Board Settings",
    "Rows",
    " (q) ⬆  (a) ⬇",
    "Columns",
    " (w) ⬆  (s) ⬇",
    "Bombs",
    " (e) ⬆  (d) ⬇",
    "(M)ain menu"
  ]

  MIN_ROWS = 3
  MIN_COLUMNS = 8
  MAX_ROWS = 99
  MAX_COLUMNS = 99
  MIN_BOMBS = 1

  def initialize
    @custom_rows = 10
    @custom_columns = 10
    @custom_bombs = 10
  end

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
    current_menu = MAIN_MENU.dup

    current_menu[4] += " #{@custom_rows} x #{@custom_columns} Bombs: #{@custom_bombs}"
    current_menu.join("\n")
  end


  def increase_rows
    @custom_rows += 1 unless @custom_rows == MAX_ROWS
  end

  def decrease_rows
    @custom_rows -= 1 unless @custom_rows == MIN_ROWS
    @custom_bombs = [@custom_bombs, max_custom_bombs].min
  end

  def increase_columns
    @custom_columns += 1 unless @custom_columns == MAX_COLUMNS
  end

  def decrese_columns
    @custom_columns -= 1 unless @custom_columns == MIN_COLUMNS
    @custom_bombs = [@custom_bombs, max_custom_bombs].min
  end

  def increse_bombs
    @custom_bombs += 1 unless @custom_bombs == max_custom_bombs
  end

  def decrease_bombs
    @custom_bombs -= 1 unless @custom_bombs == MIN_BOMBS
  end

  def max_custom_bombs
    @custom_rows * @custom_columns - 1
  end

# "Custom Board Settings",
# "Rows",
# " (q) ⬆  (a) ⬇",
# "Columns",
# " (w) ⬆  (s) ⬇",
# "Bombs",
# " (e) ⬆  (d) ⬇",
# "(M)ain menu"
  def display_custom_menu
    current_menu = CUSTOM_MENU.dup

    current_menu[1] += " #{@custom_rows}"
    current_menu[3] += " #{@custom_columns}"
    current_menu[5] += " #{@custom_bombs}"
    current_menu.join("\n")
  end

  def run_custom_menu
    Dispel::Screen.open do |screen|
      screen.draw(display_custom_menu)

      Dispel::Keyboard.output do |key|
        case key
        when 'q' then increase_rows
        when 'a' then decrease_rows
        when 'w' then increase_columns
        when 's' then decrese_columns
        when "e" then increse_bombs
        when 'd' then decrease_bombs
        when 'm' then break
        end

        screen.draw(display_custom_menu)
      end
    end
  end

  def run_main_menu
    Dispel::Screen.open do |screen|
      screen.draw(display_main_menu)

      Dispel::Keyboard.output do |key|
        case key
        when 'b' then run_game(Game.new(9, 9, 10))
        when 'i' then run_game(Game.new(16, 16, 40))
        when 'e' then run_game(Game.new(16, 30, 99))
        when 'c' then run_game(Game.new(@custom_rows, @custom_columns, @custom_bombs))
        when 'l'
          game = Game.load
          run_game(game) unless game.nil?
        when 's' then run_custom_menu
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
