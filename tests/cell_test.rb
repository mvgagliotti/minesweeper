require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'set'
require './lib/minesweeper/minesweeper'
require './lib/minesweeper/constants'
require './lib/minesweeper/cell'

#
# Testes para a classe Cell
#
class CellTest < Test::Unit::TestCase

  def test_json()

    cell = Cell.new(1,2, false)
    json = cell.to_json()
    from_json = Cell.from_json(json)

    assert_equal(from_json.x, 1)
    assert_equal(from_json.y, 2)
    assert_false(from_json.has_bomb)
    assert_false(from_json.is_flaged)
    assert_false(from_json.has_been_clicked)
  end

  #
  # Testa criação de uma célula
  #
  def test_cell_creation()

    cell = Cell.new(2,4,false)
    assert_false(cell.has_bomb)
    assert_equal(2, cell.x)
    assert_equal(4, cell.y)
    assert_false(cell.has_been_clicked)

    bomb_cell = Cell.new(2,4,true)
    assert_true(bomb_cell.has_bomb)
  end

  #
  # Testando click
  #
  def test_cell_click()

    clean_cell = Cell.new(0,0,false)
    clean_cell.click()
    assert_true(clean_cell.has_been_clicked)
    assert_false(clean_cell.flag())

  end

  #
  # Testa flag de célula
  #
  def test_cell_flag()

    # flaga e depois clica (o click nao faz nada)
    cell = Cell.new(2,4,false)
    assert_true(cell.flag())
    assert_false(cell.click())

    #desflaga e clica
    assert_true(cell.flag())
    assert_true(cell.click())

    #após clicar, clique e flag retornam false
    assert_false(cell.flag())
    assert_false(cell.click())

  end

  #
  # Testando método value() para célula limpa
  #
  def test_cell_value_for_clean_cell()

    cell = Cell.new(2,4,false)
    assert_equal(Constants::UNKNOWN_CELL, cell.value())
    assert_equal(Constants::UNKNOWN_CELL, cell.value(true))

    cell.click()
    assert_equal(Constants::EMPTY, cell.value())
  end

  #
  # Testando método value() para célula com bomba
  #
  def test_cell_value_for_bomb_cell()
    cell = Cell.new(2,4,true)
    assert_equal(Constants::UNKNOWN_CELL, cell.value())
    assert_equal(Constants::BOMB, cell.value(true))

    cell.click()
    assert_equal(Constants::BOMB, cell.value())
    assert_equal(Constants::BOMB, cell.value(true))

  end

  #
  #  Testando método value() para célula flagada limpa
  #
  def test_cell_value_for_flagged_clean_cell()

    cell = Cell.new(2,4,false)
    assert_equal(Constants::UNKNOWN_CELL, cell.value())
    assert_equal(Constants::UNKNOWN_CELL, cell.value(true))

    cell.flag()
    assert_equal(Constants::FLAGGED, cell.value())
    assert_equal(Constants::FLAGGED, cell.value(true))

  end

  #
  #  Testando método value() para célula flagada com bomba
  #
  def test_cell_value_for_flagged_bomb_cell()

    cell = Cell.new(2,4,true)
    assert_equal(Constants::UNKNOWN_CELL, cell.value())
    assert_equal(Constants::BOMB, cell.value(true))

    cell.flag()
    assert_equal(Constants::FLAGGED, cell.value())
    assert_equal(Constants::BOMB, cell.value(true))

  end


  if __FILE__ == $0
    Test::Unit::UI::Console::TestRunner.run(CellTest)
  end

end