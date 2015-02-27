require_relative "board.rb"
class Game
  attr_accessor :board, :current_player, :player1, :player2

  def initialize
    @board = Board.new
    @board.place_pieces
    @current_player = :light_white
    @player1 = Player.new(:light_white, board)
    @player2 = Player.new(:black, board)
  end

  def play
    until board.won?
      begin
        board.render
        if current_player == :light_white
          player = player1
        else
          player = player2
        end
        player.play_turn(current_player)
        if current_player == :light_white
          current_player = :black
        elsif current_player == :black
          current_player = :light_white
        end
      rescue ArgumentError => e
        puts "#{e.message}"
        retry
      rescue RuntimeError => e
        puts "#{e.message}"
        retry
      end
    end
    puts "#{current_player} won!"
  end
end

class Player
  attr_reader :color, :board

  def initialize(color, board)
    @color = color
    @board = board
  end

  def play_turn(color)
    puts "#{color.to_s}, which piece would you like to move?"
    puts "Please enter row_number and column number separated by a comma : 1,1"
    from_pos = gets.chomp.split(",")
    if from_pos.length != 2
      raise ArgumentError.new("Wrong number of arguments. Please follow format")
    end
    from_pos = [from_pos[0].to_i - 1, from_pos[1].to_i - 1]
    # if board[from_pos].color != color
    #   raise ArgumentError.new("You must move your own piece")
    # end
    puts "#{color.to_s}, where would you like to move your chosen piece?"
    puts "Please enter row_number and column number separated by a comma : 1,1"
    puts "If you would like to jump multiple pieces, separate each pair with"
    puts "two commas: 1,1,,2,2"
    to_pos_string = gets.chomp.split(",,")

    to_pos = []
    to_pos_string.each do |str_pair|
      pair = str_pair.split(",")
      if pair.length != 2
        raise ArgumentError.new("Wrong number of arguments. Please follow format")
      end
      to_pos << [pair[0].to_i - 1, pair[1].to_i - 1]
    end

    board[from_pos].perform_moves(to_pos)

  end
end
