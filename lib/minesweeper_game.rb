require_relative 'minesweeper/console_client'

#
# Classe "root" p/ executar o jogo via console
#
class MinesweeperGame

  def console_play()
    ConsoleClient.new().console_play()
  end

end