# encoding: utf-8
require 'dispel'
require './minesweeper_board.rb'
require 'yaml'
require './leaderboard.rb'

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
    File.open(file_name, 'w') do |f|
      f.puts self.to_yaml
    end
  end

  def start_timer
    @start_time = Time.new
  end

  def end_timer
    @end_time = Time.new
  end

  def reveal
    start_timer if @start_time.nil?
    old_win = board.won?
    @board.reveal(position)
    end_timer if board.won? || board.loss?
    return true if board.won? && !old_win
    false
  end

  def get_time
    return nil if @end_time.nil?
    @end_time - @start_time
  end

  def flag
    @board.flag(position)
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
  LEADERBOARD_HEADER = "Leaderboard"
  LEADERBOARD_NAME = {
    beginner: "Beginner",
    intermediate: "Intermediate",
    expert: "Expert"
  }

  LEADERBOARD_INSTRUCTIONS = "(B)eginner (I)ntermediate (E)xpert (M)ain menu"

  MIN_ROWS = 3
  MIN_COLUMNS = 8
  MAX_ROWS = 99
  MAX_COLUMNS = 99
  MIN_BOMBS = 1

  def initialize(user_name)
    @user_name = user_name
    @custom_rows = 10
    @custom_columns = 10
    @custom_bombs = 10
    @leaderboard = Leaderboard.load
  end

  def display_game(screen, game)
    game_board = game.board.display

    if game.board.won?
      game_board << "\nWin!"

    elsif game.board.alive
      game_board << "\nAlive"
    else
      game_board << "\nYou dead :("
    end

    game_board << "\n (f)lag (space)reveal (M)ain menu (s)ave"

    game_board << "\n #{game.get_time}" unless game.get_time.nil?

    screen.draw(game_board, [], game.position)
  end

  def run_game(game, game_type)

    Dispel::Screen.open do |screen|
      display_game(screen, game)

      Dispel::Keyboard.output do |key|
        case key
        when :up then game.up
        when :left then game.left
        when :right then game.right
        when :down then game.down
        when "m" then break
        when " "
          if game.reveal && game_type != :custom
            case game_type
            when :beginner
              @leaderboard.add_beginner_time(@user_name, game.get_time )
            when :intermediate
              @leaderboard.add_intermediate_time(@user_name, game.get_time )
            when :expert
              @leaderboard.add_expert_time(@user_name, game.get_time )
            end
          end
        when "f" then game.flag
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

  def display_leaderboard(current_leaderboard)
    top_times = @leaderboard.send(current_leaderboard)
    top_strings = top_times.map.with_index do |leaderboard, index|
      "#{index + 1}. #{leaderboard.first} #{leaderboard.last}"
    end
    leaderboard_array = [LEADERBOARD_HEADER, LEADERBOARD_NAME[current_leaderboard]]
    leaderboard_array.concat(top_strings)
    leaderboard_array += [LEADERBOARD_INSTRUCTIONS]
    leaderboard_array.join("\n")
  end

  def run_leaderboard
    Dispel::Screen.open do |screen|
      current_leaderboard = :beginner
      screen.draw(display_leaderboard(current_leaderboard))

      Dispel::Keyboard.output do |key|
        case key
        when 'b' then current_leaderboard = :beginner
        when 'i' then current_leaderboard = :intermediate
        when 'e' then current_leaderboard = :expert
        when 'm' then break
        end

        screen.draw(display_leaderboard(current_leaderboard))
      end
    end
  end

  def clear_main_menu(screen)
    clear_string = display_main_menu
    clear_string.gsub!(/[^\n]/, ' ')
    screen.draw(clear_string)
  end

  def run_main_menu
    Dispel::Screen.open do |screen|
      screen.draw(display_main_menu)

      Dispel::Keyboard.output do |key|
        case key
        when 'b'
          clear_main_menu(screen)
          run_game(Game.new(9, 9, 10), :beginner)
        when 'i'
          clear_main_menu(screen)
          run_game(Game.new(16, 16, 40), :intermediate)
        when 'e'
          clear_main_menu(screen)
          run_game(Game.new(16, 30, 99), :expert)
        when 'c'
          clear_main_menu(screen)
          run_game(Game.new(@custom_rows, @custom_columns, @custom_bombs), :custom)
        when 'l'
          clear_main_menu(screen)
          game = Game.load
          run_game(game) unless game.nil?
        when 's'
          clear_main_menu(screen)
          run_custom_menu
        when 'a'
          clear_main_menu(screen)
          run_leaderboard
        when 'x' then exit
        end

        screen.draw(display_main_menu)
      end
    end
  end

  def leaderboard
  end

end

if __FILE__ == $PROGRAM_NAME

  user = ARGV.shift

  display = Display.new(user)

  display.run_main_menu

end
