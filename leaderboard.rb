require 'yaml'

class Leaderboard
  FILE_NAME = "leaderboard.txt"
  LEADERBOARD_SIZE = 10
  attr_accessor :beginner, :intermediate, :expert

  def initialize
    @beginner = [["minesweeper", 999]]
    @intermediate = [["minesweeper", 999]]
    @expert = [["minesweeper", 999]]
  end

  def self.load
    if File.file?(FILE_NAME)
      file = File.read(FILE_NAME)
      YAML::load(file)
    else
      Leaderboard.new
    end
  end

  def save
    File.open(FILE_NAME, 'w') do |f|
      f.puts self.to_yaml
    end
  end

  def add_beginner_time(name, time)
    add_leaderboard_time(beginner, name, time)
  end

  def add_intermediate_time(name, time)
    add_leaderboard_time(intermediate, name, time)
  end

  def add_expert_time(name, time)
    add_leaderboard_time(expert, name, time)
  end

  private
  def add_leaderboard_time(leaderboard, name, time)
    leaderboard << [name, time]
    leaderboard.sort! { |x, y| x.last <=> y.last }
    leaderboard.delete_at(LEADERBOARD_SIZE)
    save
  end

end
