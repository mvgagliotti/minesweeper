require_relative 'minesweeper'
require_relative 'constants'
require_relative 'cell'
require_relative 'board_printer'

#
# Classe para debugar o game
#
class Debug

  def run()
    puts "Hello! "
  end

  def assert_equal(expected, actual, message)
    if !(expected == actual)
      raise "Expected #{expected} but got #{actual} instead"
    end
    puts "Assertion passed!"
  end

  def test_block()
    yield 5 if block_given?
  end

  def test_saving()
    Minesweeper.new(2,1,1).save_state("#{ENV['HOME']}/test_saving")
  end



  def test_json()

    cell = Cell.new(1,2, false)
    json = cell.to_json()
    from_json = Cell.from_json(json)
    puts "#{from_json}"

    # assert_equal(from_json.x, 1)
    # assert_equal(from_json.y, 2)
    # assert_false(from_json.has_bomb)
    # assert_false(from_json.is_flaged)
    # assert_false(from_json.has_been_clicked)
  end

  def test_game_state_saving()

    minesweeper = Minesweeper.new(2,3,0)
    minesweeper.build_board([[0,0]].to_set())

    minesweeper.play(1,0)

    minesweeper.save_state("#{ENV['HOME']}/minesweeper_state")
    minesweeper = Minesweeper.recover_from_disk("#{ENV['HOME']}/minesweeper_state")

    # board_state =  minesweeper.board_state()
    # board_assertion([['?', '1'],
    #                  ['?', '?'],
    #                  ['?', '?']], board_state)
  end

  if __FILE__ == $0
    Debug.new().test_game_state_saving()
  end
end