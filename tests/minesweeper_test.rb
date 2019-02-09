require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'set'
require './lib/minesweeper/minesweeper'
require './lib/minesweeper/constants'

#
# Suite de testes para o game
#
class MinesweeperTest < Test::Unit::TestCase


  def test_game_state_saving()

    minesweeper = Minesweeper.new(2,3,0)
    minesweeper.build_board([[0,0]].to_set())

    minesweeper.play(1,0)

    minesweeper.save_state("#{ENV['HOME']}/minesweeper_state")
    minesweeper = Minesweeper.recover_from_disk("#{ENV['HOME']}/minesweeper_state")

    board_state =  minesweeper.board_state()
    board_assertion([['?', 1],
                              ['?', '?'],
                              ['?', '?']], board_state)
  end

  #
  # Teste básico: jogada próxima a uma bomba
  #
  def test_boardstate_for_bomb_closer()

    minesweeper = Minesweeper.new(2,3,0)
    minesweeper.build_board([[0,0]].to_set())

    minesweeper.play(1,0)

    board = minesweeper.board_state()

    assert_equal(Constants::UNKNOWN_CELL, board[0][0])
    assert_equal(1, board[1][0])
  end

  #
  # Testa o retorno de board_state ao jogar em uma célula cercada por bombas.
  #
  # Verifica se a contagem de bombas adjacentes está correta;
  #
  # Board p/ teste:
  #
  #    0  1  2  3  4
  # 0 [B][ ][ ][ ][ ]
  # 1 [ ][ ][B][ ][B]
  # 2 [ ][ ][ ][ ][ ]
  # 3 [ ][ ][B][ ][ ]
  # 4 [ ][ ][ ][ ][ ]
  #
  def test_board_state_when_playing_at_cell_with_bombs_around()


    #definindo onde colocar as bombas
    bombs = [[0,0], [2,1], [4,1], [2,3]].to_set()

    #construindo o board
    minesweeper = Minesweeper.new(5,5,0)
    minesweeper.build_board(bombs)
    board_state = minesweeper.board_state()

    #assert inicial: todas células cobertas
    board_assertion([
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?']],board_state)

    #[1,1] -> 2 bombas ao redor
    minesweeper.play(1,1)
    board_state = minesweeper.board_state()
    assert_equal(2, board_state[1][1], "Esperava ter encontrado 2 bombas ao redor de [1,1]")
    board_assertion([
                        ['?','?','?','?','?'],
                        ['?', 2, '?','?','?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?']],board_state)

    #[3,2] -> 3 bombas ao redor
    minesweeper.play(3,2)
    board_state = minesweeper.board_state()
    assert_equal(3, board_state[3][2], "Esperava ter encontrado 3 bombas ao redor de [3,2]")
    board_assertion([
                        ['?','?','?','?','?'],
                        ['?', 2, '?','?','?'],
                        ['?','?','?', 3, '?'],
                        ['?','?','?','?','?'],
                        ['?','?','?','?','?']],board_state)

  end


  #
  # Testa o raio-x do board_state
  #
  #  Board p/ teste:
  #    0  1  2  3  4
  # 0 [B][ ][ ][ ][ ]
  # 1 [ ][ ][B][ ][B]
  # 2 [ ][ ][ ][ ][ ]
  # 3 [ ][ ][B][ ][ ]
  # 4 [ ][ ][ ][ ][ ]
  #
  def test_xray_board_state()
    #definindo onde colocar as bombas
    bombs = [[0,0], [2,1], [4,1], [2,3]].to_set()

    #construindo o board
    minesweeper = Minesweeper.new(5,5,0)
    minesweeper.build_board(bombs)
    board_state = minesweeper.board_state(xray:true)

    #assert inicial: todas células cobertas
    board_assertion([
                        ['B','?','?','?','?'],
                        ['?','?','B','?','B'],
                        ['?','?','?','?','?'],
                        ['?','?','B','?','?'],
                        ['?','?','?','?','?']],board_state)
  end



  #
  # Testa funcionalidade de clique em célula não cercada por bombas e subsequente abertura
  # de células adjacentes
  #
  #  Board p/ teste:
  #    0  1  2  3  4
  # 0 [B][ ][ ][ ][ ]
  # 1 [ ][ ][B][ ][B]
  # 2 [ ][ ][ ][ ][ ]
  # 3 [ ][ ][B][ ][ ]
  # 4 [ ][ ][ ][ ][ ]
  #
  def test_board_state_for_play_at_cell_without_bombs_around()
    #definindo onde colocar as bombas
    bombs = [[0,0], [2,1], [4,1], [2,3]].to_set()

    #construindo o board
    minesweeper = Minesweeper.new(5,5,0)
    minesweeper.build_board(bombs)

    minesweeper.play(0,2)
    board_state = minesweeper.board_state()

    board_assertion([
                        ['?','?','?','?','?'],
                        [1 ,  2,'?','?','?'],
                        [' ', 2,'?','?','?'],
                        [' ', 1,'?','?','?'],
                        [' ', 1,'?','?','?']],board_state)

  end

  #
  # Faz 3 jogadas até vencer
  #
  def test_game_state_for_victory()

    #construindo o board
    minesweeper = Minesweeper.new(2,2,0)
    minesweeper.build_board([[0,0]].to_set())

    minesweeper.play(1,0)
    assert_false(minesweeper.victory?)

    minesweeper.play(1,1)
    assert_false(minesweeper.victory?)

    minesweeper.play(0,1)
    assert_equal(false, minesweeper.still_playing?)
    assert_equal(true, minesweeper.victory?)

  end

  #
  # Testa jogo perdido
  #
  def test_game_state_for_defeat()

    #construindo o board
    minesweeper = Minesweeper.new(2,2,0)
    minesweeper.build_board([[0,0]].to_set())

    minesweeper.play(0,0)
    assert_equal(false, minesweeper.still_playing?)
    assert_equal(false, minesweeper.victory?)

  end

  #
  # Testa a lógica de flagar célula
  #
  def test_flagging_cell()

    #construindo o board
    minesweeper = Minesweeper.new(2,2,0)
    minesweeper.build_board([[0,0]].to_set())

    #flagando 0,0
    valid = minesweeper.flag(0,0)
    assert_true(valid)
    assert_equal(Constants::FLAGGED, minesweeper.board_state()[0][0])
    assert_true(minesweeper.still_playing?)
    assert_false(minesweeper.victory?)

    # clicando em célula flagada
    valid = minesweeper.play(0,0)
    assert_false(valid)

    #desflagando
    valid = minesweeper.flag(0,0)
    assert_true(valid)
    assert_equal(Constants::UNKNOWN_CELL, minesweeper.board_state()[0][0])
    assert_true(minesweeper.still_playing?)
    assert_false(minesweeper.victory?)

    # clicando na bomba e perdendo
    valid = minesweeper.play(0,0)
    assert_false(minesweeper.still_playing?)
    assert_false(minesweeper.victory?)

  end

  #
  # facilitador para assertions de board_state
  #
  def board_assertion(expected, actual)
    inverse = expected.transpose() # inverte a matriz linhaXcoluna passada p/ colunaXlinha
    assert_equal(inverse,actual)
  end

  if __FILE__ == $0
    Test::Unit::UI::Console::TestRunner.run(MinesweeperTest)
  end

end
