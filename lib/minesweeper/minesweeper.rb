require_relative 'cell'
require 'set'
require 'json'

#
# Classe principal do game. Possui a API especificada nos requisitos do projeto
#
class Minesweeper

  attr_reader :num_mines

  def initialize(width, height, num_mines, cells=nil, still_playing=nil, victory=nil)
    @num_mines = num_mines
    @width = width
    @height = height
    @cells = cells == nil ? Array.new : cells
    @still_playing= still_playing == nil ? true : still_playing
    @victory = victory == nil ? false: victory

    if (num_mines > (width*height))
      raise "Número de bombas maior do que o tamanho do tabuleiro"
    end

    if (cells == nil and num_mines > 0)
      build_board(num_mines)
    end
  end

  #
  # Constrói o tabuleiro, colocando as bombas em lugares aleatórios
  #
  def build_board(mines)

    if (mines.is_a?(Set))
      bomb_coords = mines
      @num_mines = mines.size
    else
      bomb_coords = bomb_coordinates(@width, @height, mines)
    end

    # construindo o board
    (0..@width-1).each do |x|
      @cells << Array.new
      (0..@height-1).each do |y|
        has_bomb = bomb_coords.select { |coord| coord[0] == x && coord[1] == y }.length > 0
        @cells[@cells.length-1] << Cell.new(x, y, has_bomb)
      end
    end

    return self
  end

  #
  # Gera as coordenadas das bombas randomicamente e retorna um hash
  #
  protected def bomb_coordinates(width,height,num_bombs)

    bomb_coords = Set.new()

    while bomb_coords.length < num_bombs
      x = rand(width)
      y = rand(height)
      bomb_coords.add([x,y])
    end

    return bomb_coords
  end

  #
  # Executa uma jogada na coordenada especificada no tabuleiro.
  #
  def play(x,y)

    if (!@still_playing)
      return false
    end

    cell = get_cell_at(x, y)

    # clica na célula
    cell_click_result = cell_click(cell)

    if (cell_click_result)
      # verifica se jogo acabou
      if (cell.has_bomb)
        @victory = false
        @still_playing = false
      else
        cheeck_for_victory()
      end
    end

    return cell_click_result
  end

  protected def get_cell_at(x, y)
    cell = @cells[x][y] #retorna null se coordenada estiver fora do intervalo
    if (cell == nil)
      raise "Coordenadas especificadas fora do intervalo: [#{x},#{y}]"
    end
    cell
  end

  #
  # Flaga a a célula especificada. Retorna true caso a jogada tenha sido válida e false do contrário
  #
  def flag(x,y)

    if (!@still_playing)
      return false
    end

    cell = get_cell_at(x, y)

    # clica na célula
    return cell.flag()
  end

  #
  # Retorna true se o jogo ainda ñ acabou
  #
  def still_playing?()
    return @still_playing
  end

  #
  # Retorna true caso o usuário tenha vencido
  #
  def victory?()
    return !@still_playing && @victory
  end

  #
  # Checa se o jogador venceu
  #
  protected def cheeck_for_victory()

    clicked = 0

    (0..@cells.length-1).each do |x|
      (0..@cells[x].length-1).each do |y|
        cell = @cells[x][y]
        clicked += cell.has_been_clicked ? 1 : 0
      end
    end

    if (clicked == ((@width*@height)-@num_mines))
      @victory = true
      @still_playing = false
    end

  end

  #
  # Retorna uma representação do estado do tabuleiro
  #
  def board_state(options={})
    result = []
    (0..@cells.length-1).each do |x|
      result << []
      (0..@cells[x].length-1).each do |y|
        result[x] << @cells[x][y].value(options[:xray]==true)
      end
    end
    return result
  end

  #
  # Processa um "click" em uma célula
  #
  protected def cell_click(cell)
    valid = cell.click()
    if (valid)

      if (cell.has_bomb)
        return valid
      end

      # encontra as adjacentes
      adjacent_cells = find_adjacent_cells(cell)

      # verifica possíveis bombas adjacentes
      adjacent_cells_with_bomb =
        adjacent_cells.select do |adj_cell|
          adj_cell.has_bomb
        end

      # seta o número de bombas ao redor
      cell.num_of_bombs_around = adjacent_cells_with_bomb.length

      # se ñ houver bombas ao redor, clica em cada uma das adjacentes
      if (cell.num_of_bombs_around == 0)
        for adj_cell in adjacent_cells
          cell_click(adj_cell)
        end
      end

    end
    return valid
  end

  #
  # Encontra as células adjacentes à célula passada
  #
  protected def find_adjacent_cells(cell)
    adjacents = []

    adjacents << ((cell.y+1 < @height) ? @cells[cell.x][cell.y+1] : nil)
    adjacents << ((cell.x-1 >= 0 && cell.y+1 < @height) ? @cells[cell.x-1][cell.y+1] : nil)
    adjacents << ((cell.x-1 >= 0) ? @cells[cell.x-1][cell.y] : nil)
    adjacents << ((cell.x-1 >= 0 && cell.y-1 >= 0) ? @cells[cell.x-1][cell.y-1] : nil)
    adjacents << ((cell.y-1 >= 0) ? @cells[cell.x][cell.y-1]: nil)
    adjacents << ((cell.x+1 < @width && cell.y-1 >=0) ? @cells[cell.x+1][cell.y-1] : nil)
    adjacents << ((cell.x+1 < @width) ? @cells[cell.x+1][cell.y] : nil)
    adjacents << ((cell.x+1 < @width && cell.y+1 < @height) ? @cells[cell.x+1][cell.y+1] : nil)

    return adjacents.compact()
  end

  def self.recover_from_disk(path)
    open(path, 'r') do |f|
      num_mines = f.gets().split(":")
      num_mines = num_mines[1].gsub("\n", "").to_i

      width = f.gets().split(":")
      width = width[1].gsub("\n", "").to_i

      height = f.gets().split(":")
      height = height[1].gsub("\n", "").to_i

      still_playing = f.gets().split(":")
      still_playing = still_playing[1].gsub("\n", "") == "true"

      victory = f.gets().split(":")
      victory = victory[1].gsub("\n", "") == "true"

      cells_json = f.gets()
      cells_hash = JSON.parse(cells_json)

      (0..cells_hash.length-1).each do |x|
        (0..cells_hash[x].length-1).each do |y|
          cell = Cell.from_hash(cells_hash[x][y])
          cells_hash[x][y] = cell
        end
      end

      new_game = Minesweeper.new(width, height, num_mines, cells_hash, still_playing, victory)
      return new_game
    end
  end

  #
  # Salva o estado do jogo
  #
  def save_state(path)

    open(path, 'w') { |f|

      # primeiramente, salvando atributos simples no arquivo, por linha
      f.puts "\"num_mines\":#{@num_mines}"
      f.puts "\"width\":#{@width}"
      f.puts "\"height\":#{@height}"
      f.puts "\"still_playing\":#{@still_playing}"
      f.puts "\"victory\":#{@victory}"

      #salvando estado do board
      f.print "["
      (0..@cells.length-1).each_with_index do |x, x_index|
        f.print("[")

        (0..@cells[x].length-1).each_with_index do |y, index|
          if (index == @cells[x].length-1)
            f.print("#{@cells[x][y].to_json()}")
          else
            f.print("#{@cells[x][y].to_json()},")
          end
        end

        if (x_index == @cells.length-1)
            f.print("]")
          else
            f.print("],")
        end
      end
      f.print "]"
      f.close()
    }
  end

end