#
# Impressor de tabuleiro
#
class BoardPrinter

  #
  # Imprime o estado do tabuleiro
  #
  def print(board)

    first_line = "[X]"
    (0..board.length-1).each{|i| first_line += "[#{i}]"}
    puts first_line

    row_count = board[0].length
    line_index = 0
    (0..row_count-1).each do |y|
      line = "[#{line_index}]"
      (0..board.length-1).each do |x|
        line += "[#{board[x][y]}]"
      end
      line_index += 1
      puts line
    end

  end

end