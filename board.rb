require_relative 'piece.rb'
require 'byebug'

class Board
  attr_accessor :grid

  def initialize
    @grid = make_grid
#    place_pieces
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @grid[x][y] = piece
  end

  def make_grid
    Array.new(8) { Array.new(8) }
  end

  def place_pieces
    grid.each_with_index do |row, row_i|
      grid.each_index do |col_i|
        pos = [row_i, col_i]
        if (col_i.even? && row_i.even? && row_i.between?(0, 2)) ||
           (col_i.odd? && row_i.odd? && row_i == 1)

          @grid[row_i][col_i] = Piece.new(pos, self, :light_white)
        elsif (col_i.odd? && row_i.odd? && row_i.between?(5, 7)) ||
              (col_i.even? && row_i.even? && row_i == 6)
          @grid[row_i][col_i] = Piece.new(pos, self, :black)
        end
      end
    end
  end

  def render
    board_display = grid.map.with_index do |row, i|
      row.map.with_index do |piece, j|
        if piece.nil?
          "   "
        else
          piece.symbol
        end
      end
    end
    board_display = set_background(board_display)

    puts board_display
  end

  def set_background(board)
    board.map.with_index do |row, i|
      row.map.with_index do |space, j|
        if (i.even? && j.even?) || (i.odd? && j.odd?)
          space.colorize(:background => :light_red)
        else
          space.colorize(:background => :light_yellow)
        end
      end.join.reverse
    end.join("\n").reverse
  end

  def dup
    new_grid = Board.new
    @grid.flatten.compact.each do |piece|
      new_grid[piece.position] = Piece.new(piece.position.dup, new_grid, piece.color, piece.king_status)
    end
    new_grid
  end

  def won?
    colors = []
    @grid.flatten.compact.each do |piece|
      colors << piece.color unless colors.include?(piece.color)
    end

    if colors.length == 1
      return true
    else
      return false
    end
  end
end
