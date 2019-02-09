require_relative 'constants'
require 'json'

#
# Classe para representar uma célula no tabuleiro.
#
class Cell

  attr_reader :x,:y, :has_been_clicked, :has_bomb, :is_flaged
  attr_accessor :num_of_bombs_around

  def initialize(x,y,has_mine,is_flaged=nil,has_been_clicked=nil, num_of_bombs_around=nil)
    @x = x
    @y = y
    @has_bomb = has_mine
    @is_flaged = is_flaged == nil ? false : is_flaged
    @has_been_clicked = has_been_clicked == nil ? false : has_been_clicked
    @num_of_bombs_around = num_of_bombs_around
  end

  #
  # "clica" na célula e a marca como clicada.
  #
  # Retorna true se operação tiver sido válida, ou seja, célula não flagada e não clicada anteriormente.
  # Retorna false do contrário
  #

  def click()
    if (@has_been_clicked || @is_flaged)
      return false
    end
    @has_been_clicked = true
    return true
  end

  #
  # Marca ou desmarca a célula com uma flag. Retorna true se operação for válida ou false caso a célula já
  # tenha sido clicada.
  #
  def flag()
    if @has_been_clicked
      return false
    end
    @is_flaged = !@is_flaged
    return true
  end

  #
  # Retorna o valor da célula:
  #
  # '?' se ñ tiver sido revelado ainda e parâmetro show_bomb = false
  # 'B' se tiver bomba ou não clicado mas com show_bombs=true;
  # 'F' se flagado;
  #  número de bombas adjacentes se vazio e houver bombas ao redor;
  # ' ' se ñ houver bombas ao redor
  #
  def value(show_bomb=false)
    if (@has_been_clicked)
      if (@has_bomb)
        return Constants::BOMB
      elsif @num_of_bombs_around != nil && @num_of_bombs_around > 0
        return @num_of_bombs_around
      end

      return Constants::EMPTY
    end

    if (@is_flaged)
      if (show_bomb == false)
        return Constants::FLAGGED
      else
        return @has_bomb ? Constants::BOMB : Constants::FLAGGED
      end
    end

    if (show_bomb == false)
      return Constants::UNKNOWN_CELL
    end

    return @has_bomb ? Constants::BOMB : Constants::UNKNOWN_CELL
  end

  #
  # Representação string da célula
  #
  def to_s()
    val = value()
    if (!val.is_a?(String))
      return "#{val}"
    end
    return val
  end

  #
  # Gera um json a partir da célula
  #
  def to_json()
    return "{\"x\": #{@x}, \"y\": #{@y}, \"has_bomb\": #{@has_bomb}, \"is_flaged\": #{@is_flaged}, \"has_been_clicked\": #{@has_been_clicked}, \"num_of_bombs_around\": #{@num_of_bombs_around ? @num_of_bombs_around : 0 }}"
  end

  #
  # Retorna uma célula a partir de um json
  #
  def self.from_json(string)
    hash = JSON.parse(string)
    cell = Cell.new(hash['x'], hash['y'], hash['has_bomb'] == "true")
    return cell
  end

  def self.from_hash(hash)
    cell = Cell.new(hash['x'].to_i,
                    hash['y'].to_i,
              hash['has_bomb'] == true,
              hash['is_flaged'] == true,
       hash['has_been_clicked'] == true,
                    hash['num_of_bombs_around'] == 0 ? nil : hash['num_of_bombs_around'])
  end

end