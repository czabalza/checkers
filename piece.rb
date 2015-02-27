require_relative "board.rb"
require 'unicode'
require 'colorize'
require 'byebug'

class Piece
  attr_accessor :position, :king_status, :board
  attr_reader :color
  def initialize(position, board, color, king_status = false)
    @position = position
    @board = board
    @color = color
    @king_status = king_status
  end

  def perform_slide(end_pos)
    delta = [end_pos[0] - self.position[0], end_pos[1] - self.position[1]]
    current_piece = board[position]
    if !blocked?(end_pos) && on_board?(end_pos) && move_diffs.include?(delta)

      board[end_pos] = current_piece
      board[position] = nil

      current_piece.position = end_pos
      maybe_promote
    else
      false
    end
  end

  def perform_jump(end_pos)
    current_piece = board[self.position]
    mid_delta = [((end_pos[0] - self.position[0]) / 2), ((end_pos[1] - self.position[1]) / 2)]
    mid_pos = [self.position[0] + mid_delta[0], self.position[1] + mid_delta[1]]
debugger
    if blocked?(mid_pos) && on_board?(end_pos) &&
                 move_diffs.include?(mid_delta) && !blocked?(end_pos) &&
                 board[mid_pos].color != color

      board[end_pos] = current_piece
      board[position] = nil
      board[mid_pos] = nil

      self.position = end_pos
      maybe_promote
    else
      false
    end
  end

  def perform_moves!(move_sequence)
    if move_sequence.length == 1
      value = self.perform_slide(move_sequence[0])
      value = self.perform_jump(move_sequence[0]) unless value == nil
      raise RuntimeError.new("invalid move") if value == false
    else
      move_sequence.each do |move|
        value = self.perform_jump(move)
        raise RuntimeError.new("invalid move") if value == false
      end
    end
  end

  def valid_move_seq?(move_sequence)
    begin
      new_board = board.dup
      new_board[self.position].perform_moves!(move_sequence)
      return true
    rescue
      return false
    end
  end

  def perform_moves(move_sequence)
    debugger
    if self.valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise RuntimeError.new("invalid move")
    end
  end

  def move_diffs
    if king_status
      [[1, -1], [1, 1], [-1, -1], [-1, 1]]
    elsif color == :light_white
      [[1, -1], [1, 1]]
    elsif color == :black
      [[-1, -1], [-1, 1]]
    end
  end

  def maybe_promote
    if color == :black && self.position[0] == 0
      king_status = true
    elsif color == :light_white && self.position[0] == 7
      king_status == true
    end
  end

  def blocked?(end_pos)
    if board[end_pos].nil?
      false
    else
      true
    end
  end

  def on_board?(end_pos)
    end_pos[0].between?(0, 7) && end_pos[1].between?(0,7)
  end

  def symbol
    if color == :light_white && !king_status
      " ☻ ".colorize(:light_white)
    elsif color == :black && !king_status
      " ☻ ".colorize(:black)
    elsif color == :black && king_status
      " ♛ ".colorize(:black)
    elsif color == :light_white && king_status
      " ♛ ".colorize(:light_white)
    end
  end
end
