class Skyscrapers
  attr_reader :all_possible_combinations, :possible_column_combinations, :possible_row_combinations, :grid

  SIZE = 7

  def initialize(clues:, grid: nil, all_possible_combinations: nil, possible_row_combinations: nil, possible_column_combinations: nil)
    @clues = clues
    @clue_column_set = [
      [clues[0], clues[20]],
      [clues[1], clues[19]],
      [clues[2], clues[18]],
      [clues[3], clues[17]],
      [clues[4], clues[16]],
      [clues[5], clues[15]],
      [clues[6], clues[14]]
    ]
    @clue_row_set = [
      [clues[27], clues[7]],
      [clues[26], clues[8]],
      [clues[25], clues[9]],
      [clues[24], clues[10]],
      [clues[23], clues[11]],
      [clues[22], clues[12]],
      [clues[21], clues[13]]
    ]
    @grid = grid || [
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0]
    ]
    unless solved?
      @all_possible_combinations = all_possible_combinations || generate_possible_combinations
      @possible_column_combinations = possible_column_combinations || @clue_column_set.map { |arr| find_possible_combinations(*arr) }
      @possible_row_combinations = possible_row_combinations || @clue_row_set.map { |arr| find_possible_combinations(*arr) }
      @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
      @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
    end
  end

  def main_process
    (0...SIZE).each do |row_i|
      next unless @grid[row_i].include?(0)

      (0...SIZE).each do |col_j|
        next unless @grid[row_i][col_j] == 0

        # false якщо немає можливих комбінацій
        return false if @possible_row_combinations.dig(row_i, 0, col_j).nil?

        # якщо якийсь єлемент зустрічаеться у всіх комбінаціяї, тоді він є рішенням
        if check_element(@possible_row_combinations[row_i][0][col_j], col_j, @possible_row_combinations[row_i])
          @grid[row_i][col_j] = @possible_row_combinations[row_i][0][col_j]
          @possible_row_combinations = filter_possible_combinations(@possible_row_combinations, row_i, col_j, @grid[row_i][col_j])
          @possible_column_combinations = filter_possible_combinations(@possible_column_combinations, col_j, row_i, @grid[row_i][col_j])
          @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
          @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
        end

        return false if @possible_column_combinations.dig(col_j, 0, row_i).nil?

        if check_element(@possible_column_combinations[col_j][0][row_i], row_i, @possible_column_combinations[col_j])
          @grid[row_i][col_j] = @possible_column_combinations[col_j][0][row_i]
          @possible_row_combinations = filter_possible_combinations(@possible_row_combinations, row_i, col_j, @grid[row_i][col_j])
          @possible_column_combinations = filter_possible_combinations(@possible_column_combinations, col_j, row_i, @grid[row_i][col_j])
          @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
          @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
        end
      end
    end

    true
  end

  def guess
    @grid.each_with_index do |row, row_i|
      next unless row.include?(0)

      @possible_row_combinations[row_i].each do |combination|
        tmp_grid = @grid.map(&:clone)
        tmp_grid[row_i] = combination

        new_possible_row_combinations = @possible_row_combinations.map(&:clone)
        new_possible_row_combinations[row_i] = [combination]

        sky_instans = Skyscrapers.new(
          clues: @clues,
          grid: tmp_grid,
          all_possible_combinations: @all_possible_combinations,
          possible_row_combinations: new_possible_row_combinations,
          possible_column_combinations: @possible_column_combinations.map(&:clone)
        )

        begin
          unless sky_instans.solved?
            10.times do
              grid_before = sky_instans.grid.dup
              raise unless sky_instans.main_process

              break if grid_before == sky_instans.grid
            end
          end
        rescue => e
          next
        end

        unless sky_instans.solved?
          next if sky_instans.guess == false
        end

        next unless sky_instans.valid?

        @grid = sky_instans.grid.dup

        return true
      end
    end

    if solved? && valid?
      return true
    else
      # binding.pry
      false
    end
  end

  def generate_possible_combinations(c_0=nil, c_1=nil, c_2=nil, c_3=nil, c_4=nil, c_5=nil, c_6=nil)
    arr = [1, 2, 3, 4, 5, 6, 7]
    c_0 ||= arr
    c_1 ||= arr
    c_2 ||= arr
    c_3 ||= arr
    c_4 ||= arr
    c_5 ||= arr
    c_6 ||= arr
    c_7 ||= arr

    possible = []
    c_0.each do |el_0|
      (c_1 - [el_0]).each do |el_1|
        (c_2 - [el_0, el_1]).each do |el_2|
          (c_3 - [el_0, el_1, el_2]).each do |el_3|
            (c_4 - [el_0, el_1, el_2, el_3]).each do |el_4|
              (c_5 - [el_0, el_1, el_2, el_3, el_4]).each do |el_5|
                (c_6 - [el_0, el_1, el_2, el_3, el_4, el_5]).each do |el_6|
                  possible << [el_0, el_1, el_2, el_3, el_4, el_5, el_6]
                end
              end
            end
          end
        end
      end
    end

    possible
  end

  def find_possible_combinations(clue_first, clue_last)
    out = []

    if clue_first.zero? && clue_last.zero?
      out = @all_possible_combinations
    elsif !clue_first.zero? && clue_last.zero?
      @all_possible_combinations.each do |combination|
        if find_clue(*combination) == clue_first
          out << combination
        end
      end
    elsif clue_first.zero? && !clue_last.zero?
      @all_possible_combinations.each do |combination|
        if find_clue(*combination.reverse) == clue_last
          out << combination
        end
      end
    else
      @all_possible_combinations.each do |combination|
        if find_clue(*combination) == clue_first && find_clue(*combination.reverse) == clue_last
          out << combination
        end
      end
    end

    out
  end

  def find_clue(*values)
    count = 0
    prev_val = 0
    max_val = 0

    values.each do |val|
      next if val == 0

      count += 1 if val > prev_val && val > max_val
      max_val = val if val > max_val
      prev_val = val
    end

    count
  end

  def cross_check(first_combinations, second_combinations)
    out = [[], [], [], [], [], [], []]

    present_numbers = combinations_to_numbers(second_combinations)

    (0...SIZE).each do |i|
      out_i = []

      first_combinations[i].each do |first_combination|
        if present_numbers[0][i].include?(first_combination[0]) &&
          present_numbers[1][i].include?(first_combination[1]) &&
          present_numbers[2][i].include?(first_combination[2]) &&
          present_numbers[3][i].include?(first_combination[3]) &&
          present_numbers[4][i].include?(first_combination[4]) &&
          present_numbers[5][i].include?(first_combination[5]) &&
          present_numbers[6][i].include?(first_combination[6])
          out_i << first_combination
        end
      end

      out[i] = out_i
    end

    out
  end

  # checking if all combinations has the same value in specific column
  def check_element(possible_value, index_value, combinations)
    combinations.each do |combination|
      return false unless combination[index_value] == possible_value
    end

    true
  end

  def filter_possible_combinations(combinations, row_i, col_j, element)
    out = [[], [], [], [], [], [], []]

    (0...SIZE).each do |index|
      if index == row_i
        out[index] = combinations[index].select { |el| el[col_j] == element }
      else
        out[index] = combinations[index].select { |el| el[col_j] != element }
      end
    end

    out
  end

  def solved?
    !@grid.flatten.include?(0)
  end

  def valid?
    @grid.each_with_index do |row, row_i|
      return false if row.include?(0)
      return false unless row.detect { |e| row.count(e) > 1 }.nil?
      return false if @clue_row_set[row_i][0] > 0 && @clue_row_set[row_i][0] != find_clue(*row)
      return false if @clue_row_set[row_i][1] > 0 && @clue_row_set[row_i][1] != find_clue(*row.reverse)
    end

    grid_as_columns.each_with_index do |col, col_j|
      return false if col.include?(0)
      return false unless col.detect { |e| col.count(e) > 1 }.nil?
      return false if @clue_column_set[col_j][0] > 0 && @clue_column_set[col_j][0] != find_clue(*col)
      return false if @clue_column_set[col_j][1] > 0 && @clue_column_set[col_j][1] != find_clue(*col.reverse)
    end

    true
  end

  def grid_as_columns
    out = [[], [], [], [], [], [], []]

    mapper = [
      [0, 7, 14, 21, 28, 35, 42],
      [1, 8, 15, 22, 29, 36, 43],
      [2, 9, 16, 23, 30, 37, 44],
      [3, 10, 17, 24, 31, 38, 45],
      [4, 11, 18, 25, 32, 39, 46],
      [5, 12, 19, 26, 33, 40, 47],
      [6, 13, 20, 27, 34, 41, 48],
    ]

    arr = @grid.flatten

    mapper.each_with_index do |i, index|
      out[index] = [arr[i[0]], arr[i[1]], arr[i[2]], arr[i[3]], arr[i[4]], arr[i[5]], arr[i[6]]]
    end

    out
  end

  def combinations_to_numbers(combinations)
    present_numbers = []

    (0...SIZE).each do |i|
      present_numbers_i_0 = []
      present_numbers_i_1 = []
      present_numbers_i_2 = []
      present_numbers_i_3 = []
      present_numbers_i_4 = []
      present_numbers_i_5 = []
      present_numbers_i_6 = []

      combinations[i].each do |combination|
        present_numbers_i_0 << combination[0]
        present_numbers_i_1 << combination[1]
        present_numbers_i_2 << combination[2]
        present_numbers_i_3 << combination[3]
        present_numbers_i_4 << combination[4]
        present_numbers_i_5 << combination[5]
        present_numbers_i_6 << combination[6]
      end

      present_numbers << [
        present_numbers_i_0.uniq,
        present_numbers_i_1.uniq,
        present_numbers_i_2.uniq,
        present_numbers_i_3.uniq,
        present_numbers_i_4.uniq,
        present_numbers_i_5.uniq,
        present_numbers_i_6.uniq
      ]
    end

    present_numbers
  end
end
