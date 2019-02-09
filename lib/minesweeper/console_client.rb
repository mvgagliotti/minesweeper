require_relative 'minesweeper'
require_relative 'constants'
require_relative 'cell'
require_relative 'board_printer'

#
# Client console
#
class ConsoleClient

  #
  # Permite jogar via console
  #
  def console_play()

    puts "Número de colunas:"
    width = gets.chomp.to_i

    puts "Número de linhas:"
    height = gets.chomp.to_i

    puts "Número de bombas:"
    bombs = gets.chomp.to_i

    game = Minesweeper.new(width,height,bombs)
    printer = BoardPrinter.new()

    #exibe estado
    board = game.board_state()
    printer.print(board)

    # looping do jogo
    while game.still_playing?

      puts "Entre com as coordenadas: "
      user_input = gets.chomp.to_s

      match_data = user_input.match(/(f?)(\d+),(\d+)/)
      if (match_data)

        # obtendo do input e convertendo pra int
        coords = match_data[2..3].collect{|str| Integer(str) }

        # clica ou flaga
        if !user_input.start_with?"f"
          play = game.play(coords[0], coords[1])
        else
          play = game.flag(coords[0], coords[1])
        end

        if play
          puts "jogada válida!"
        end

        #exibe estado
        board = game.board_state()
        printer.print(board)

      end
    end

    puts "Fim do jogo!"
    if game.victory?
      puts "Você venceu!"
      printer.print(game.board_state(xray:true))
    else
      puts "Você perdeu! As minas eram:"
      # PrettyPrinter.new.print(game.board_state(xray: true))
      printer.print(game.board_state(xray:true))
    end

  end

  if __FILE__ == $0
    ConsoleClient.new().console_play()
  end

end